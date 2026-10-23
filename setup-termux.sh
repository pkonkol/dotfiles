#!/data/data/com.termux/files/usr/bin/bash
# ============================================================================
#  setup-termux.sh — bootstrap Termuksa (Android, bez roota)
#  Pierwszy raz:
#    pkg install -y git just && git clone https://github.com/pkonkol/dotfiles ~/dotfiles
#    cd ~/dotfiles && just setup                  # bez flag = wszystko poza -t
#  Potem jak wszedzie: git pull && just deploy --apply
#
#  Termux z Google Play i z F-Droid: oba dzialaja, roznica tylko w termux-api (nizej).
#  Termux to nie Debian: libc to Bionic (nie glibc), nie ma sudo ani /usr,
#  wszystko siedzi w $PREFIX. Gotowe binarki pod glibc (mason, czesc LSP
#  z GitHuba) nie ruszaja — tylko to, co jest w `pkg`, npm/pip albo cargo.
# ============================================================================
set -euo pipefail
cd "$(dirname "$0")"

PKG_CORE=(zsh git tmux neovim just curl openssh)
PKG_MODERN=(eza bat fd ripgrep fzf zoxide git-delta lazygit)
PKG_MEDIA=(ffmpeg)
# schowek dla nvim + termux-share. Termux z Google Play ma je wbudowane (od 2024.07),
# wersja z F-Droid potrzebuje paczki termux-api + apki Termux:API z TEGO SAMEGO zrodla.
PKG_ANDROID=()
command -v termux-share >/dev/null || PKG_ANDROID=(termux-api)
PKG_BUILD=(clang make)          # nvim-treesitter kompiluje parsery lokalnie

ZP=~/.local/share/zsh-plugins   # .zshrc szuka pluginow tutaj, gdy nie ma /opt/homebrew
ZSH_PLUGINS=(
    romkatv/powerlevel10k
    jeffreytse/zsh-vi-mode
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-history-substring-search
    MichaelAquilina/zsh-you-should-use
)

DOTTER_VERSION=v0.13.5
FONT_URL=https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.tar.xz
FONT_FILE=JetBrainsMonoNerdFontMono-Regular.ttf

failed=()

main() {
    parse "$@"
    [[ ${DO_STORAGE:-0} -eq 1 ]] && storage
    [[ ${DO_PKG:-0}     -eq 1 ]] && packages
    [[ ${DO_ZSH:-0}     -eq 1 ]] && zsh_setup
    [[ ${DO_DEPLOY:-0}  -eq 1 ]] && deploy
    [[ ${DO_FONT:-0}    -eq 1 ]] && font
    [[ ${DO_TS:-0}      -eq 1 ]] && treesitter_cli
    command -v termux-reload-settings >/dev/null && termux-reload-settings || true

    if (( ${#failed[@]} )); then
        echo "!! nie udalo sie: ${failed[*]}"
    fi
    echo "== gotowe. Nowa sesja Termuksa (albo: exec zsh). Pierwszy nvim pobierze pluginy."
}

storage() {
    # ~/storage/{dcim,downloads,movies,shared} -> pamiec telefonu; Android pyta o zgode
    [[ -d ~/storage ]] || termux-setup-storage || failed+=(storage)
}

packages() {
    pkg update -y
    # po jednym: brak jednej paczki w repo nie wywraca reszty
    local p
    for p in "${PKG_CORE[@]}" "${PKG_MODERN[@]}" "${PKG_MEDIA[@]}" "${PKG_ANDROID[@]}" "${PKG_BUILD[@]}"; do
        pkg install -y "$p" >/dev/null 2>&1 && echo "ok  $p" || { echo "!!  $p"; failed+=("pkg:$p"); }
    done
}

zsh_setup() {
    mkdir -p "$ZP"
    local repo
    for repo in "${ZSH_PLUGINS[@]}"; do
        local dir=$ZP/${repo#*/}
        if [[ -d $dir ]]; then git -C "$dir" pull -q --ff-only || true
        else git clone -q --depth 1 "https://github.com/$repo" "$dir" || failed+=("zsh:$repo"); fi
    done
    # bindy (Ctrl-R/T, Alt-C) + ** completion w jednym pliku, raz tutaj zamiast forka przy starcie
    command -v fzf >/dev/null && fzf --zsh > "$ZP/fzf.zsh"
    [[ -d ~/.tmux/plugins/tpm ]] || git clone -q https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    [[ $(basename "${SHELL:-}") == zsh ]] || chsh -s zsh
}

deploy() {
    if ! command -v dotter >/dev/null; then
        # w repo Termuksa dottera raczej nie ma; statyczna binarka musl dziala bez glibc
        mkdir -p ~/.local/bin
        curl -fsSL -o ~/.local/bin/dotter \
            "https://github.com/SuperCuber/dotter/releases/download/$DOTTER_VERSION/dotter-linux-arm64-musl" \
            && chmod +x ~/.local/bin/dotter || { failed+=(dotter); return; }
        export PATH=~/.local/bin:$PATH
    fi
    [[ -f .dotter/local.toml ]] || echo 'packages = ["termux"]' > .dotter/local.toml
    mkdir -p ~/bin ~/.termux
    # --force: swiezy Termux ma juz wlasne ~/.termux/termux.properties
    dotter deploy -v --force || failed+=(dotter-deploy)
}

font() {
    # Termux bierze JEDEN plik ~/.termux/font.ttf, bez fallbacku, wiec "Symbols Only"
    # nie zadziala — potrzebny caly font z wszytymi ikonkami Nerd Font.
    local tmp; tmp=$(mktemp -d)
    curl -fsSL "$FONT_URL" | tar -xJ -C "$tmp" "$FONT_FILE" \
        && cp "$tmp/$FONT_FILE" ~/.termux/font.ttf || failed+=(font)
    rm -rf "$tmp"
}

treesitter_cli() {
    # nvim-treesitter (branch main) potrzebuje CLI `tree-sitter` do budowy parserow.
    # W repo Termuksa jest tylko biblioteka, wiec cargo: ~10-20 min na telefonie.
    command -v tree-sitter >/dev/null && return
    pkg install -y rust && cargo install --locked tree-sitter-cli || failed+=(tree-sitter-cli)
    echo "   ~/.cargo/bin musi byc w PATH (.zshrc to ma)"
}

parse() {
    if [[ $# -eq 0 ]]; then
        DO_STORAGE=1 DO_PKG=1 DO_ZSH=1 DO_DEPLOY=1 DO_FONT=1
        return
    fi
    while getopts "spzdfth" opt; do
        case $opt in
            s) DO_STORAGE=1 ;;
            p) DO_PKG=1 ;;
            z) DO_ZSH=1 ;;
            d) DO_DEPLOY=1 ;;
            f) DO_FONT=1 ;;
            t) DO_TS=1 ;;
            *) usage; exit 0 ;;
        esac
    done
}

usage() {
    cat <<USAGE
Uzycie: bash setup-termux.sh [flagi]     (bez flag = -s -p -z -d -f)
  -s    termux-setup-storage (~/storage -> pamiec telefonu)
  -p    pakiety z pkg
  -z    pluginy zsh (git clone do $ZP), tpm, chsh -s zsh
  -d    dotter (binarka musl, jesli brak) + deploy z packages = ["termux"]
  -f    JetBrainsMono Nerd Font Mono -> ~/.termux/font.ttf
  -t    tree-sitter CLI z cargo (wolne; bez tego nvim ma tylko wbudowane parsery)
USAGE
}

main "$@"
