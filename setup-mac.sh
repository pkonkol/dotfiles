#!/usr/bin/env bash
# ============================================================================
#  setup-mac.sh — bootstrap macOS
#  Cel: `./setup-mac.sh -b -d -f -y` ma wystarczyc. Cargo jest OPCJONALNE
#       (tylko gdy chcesz zbudowac najnowsze wersje sam).
# ============================================================================
set -euo pipefail

# --- Rdzen: bez tego nic nie dziala -----------------------------------------
BREW_CORE=(
    fish tmux neovim git
    coreutils          # gnu ls/date/... jako g-prefixed
    curl wget
)

# --- Nowoczesne zamienniki klasykow (wiekszosc w Rust) ----------------------
BREW_MODERN=(
    eza                # ls
    bat                # cat/less z podswietlaniem
    fd                 # find
    ripgrep            # grep
    sd                 # sed (prosta skladnia)
    dust               # du
    procs              # ps
    bottom             # top/htop   (binarka: btm)   <- nastepca martwego ytop
    hyperfine          # benchmark komend
    tealdeer           # tldr w Rust (binarka: tldr)
    zoxide             # cd z frecency
    fzf                # fuzzy picker
    yazi               # menedzer plikow (nastepca rangera)
    xh                 # httpie/curl do REST
    jaq                # jq w Rust
    jless              # przegladarka JSON
    tokei              # statystyki LOC
)

# --- Kolorowanie / logi ------------------------------------------------------
BREW_COLOR=(
    tailspin           # kolorowanie logow w locie (binarka: tspin)
    kubecolor          # kubectl + kolory
    grc                # generyczny kolorowacz wrapper (ping/df/traceroute/...)
    lnav               # nawigator po logach (kursor, SQL po logach)
    delta              # git diff  (formula: git-delta)
    difftastic         # diff swiadomy skladni (binarka: difft)
    bat                # (juz wyzej, ale tu tez pasuje)
)

# --- Dev / wersje runtimeow --------------------------------------------------
BREW_DEV=(
    git-delta lazygit gh
    mise               # wersje node/python/java/go per katalog (zastepuje nvm/pyenv/asdf/sdkman)
    uv                 # python packaging
    shellcheck
    direnv
)

# --- Sieciowe / reszta -------------------------------------------------------
BREW_MISC=(
    whois nmap syncthing translate-shell
    ffmpeg poppler imagemagick sevenzip   # podglady w yazi
)

# --- Casks -------------------------------------------------------------------
BREW_CASKS=(
    font-jetbrains-mono-nerd-font   # pelny patched font (litery + ikonki)
    font-symbols-only-nerd-font     # same symbole, do fallbacku w innym foncie
)

main() {
    parse "$@"

    if [[ ${INSTALL_BREW:-0} -eq 1 ]]; then
        command -v brew >/dev/null 2>&1 || \
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew update
        brew install "${BREW_CORE[@]}" "${BREW_MODERN[@]}" "${BREW_COLOR[@]}" \
                     "${BREW_DEV[@]}" "${BREW_MISC[@]}"
        brew install --cask "${BREW_CASKS[@]}"
    fi

    if [[ ${INSTALL_DOWNLOADABLE:-0} -eq 1 ]]; then
        # tmux plugin manager
        [[ -d ~/.tmux/plugins/tpm ]] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        # rust toolchain — potrzebny tylko dla -c / -u ponizej
        command -v rustup >/dev/null 2>&1 || \
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi

    if [[ ${PREPARE_FISH:-0} -eq 1 ]]; then
        # fish jako powloka logowania
        grep -qxF "$(command -v fish)" /etc/shells || command -v fish | sudo tee -a /etc/shells
        chsh -s "$(command -v fish)"
        # fisher — menedzer wtyczek fisha (jeden plik, bez frameworka)
        fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
        # bass — uruchamia skrypty bashowe i importuje ich env do fisha
        fish -c 'fisher install edc/bass'
        tldr --update
        # completions cache'owane do plikow (NIE w config.fish — to forki przy starcie)
        mkdir -p ~/.config/fish/completions
        command -v kubectl >/dev/null && kubectl completion fish > ~/.config/fish/completions/kubectl.fish
        command -v helm    >/dev/null && helm    completion fish > ~/.config/fish/completions/helm.fish
        command -v gh      >/dev/null && gh      completion -s fish > ~/.config/fish/completions/gh.fish
        command -v mise    >/dev/null && mise    completion fish > ~/.config/fish/completions/mise.fish
    fi

    # --- OPCJONALNE: zbuduj najnowsze wersje z cargo zamiast brew -----------
    if [[ ${CARGO_BUILD_ESSENTIAL:-0} -eq 1 ]]; then
        source "$HOME/.cargo/env"
        cargo install eza bat fd-find ripgrep sd git-delta zoxide tealdeer cargo-cache
    fi
    if [[ ${CARGO_BUILD_ADDITIONAL:-0} -eq 1 ]]; then
        source "$HOME/.cargo/env"
        cargo install bottom du-dust procs hyperfine tailspin yazi-fm yazi-cli xh jaq jless tokei bandwhich
    fi

    if [[ ${DEPLOY_DOTFILES:-0} -eq 1 ]]; then
        ./copy.sh
    fi
}

usage() {
    cat <<USAGE
Usage: $0 [-a] [-b] [-d] [-f] [-c] [-u] [-y]
  -a    Wszystko
  -b    Pakiety Homebrew (to jest jedyne co realnie potrzebne na macOS)
  -d    Pobierane rzeczy (tpm, rustup)
  -f    Przygotuj fisha (chsh, fisher, bass, cache completions)
  -c    OPCJA: zbuduj podstawowe narzedzia z cargo (najnowsze wersje)
  -u    OPCJA: zbuduj dodatkowe narzedzia z cargo
  -y    Wgraj dotfiles do \$HOME
USAGE
    exit 1
}

parse() {
    [[ $# -eq 0 ]] && usage
    while getopts "abdfcuy" opt; do
        case ${opt} in
            a ) INSTALL_BREW=1; INSTALL_DOWNLOADABLE=1; PREPARE_FISH=1; DEPLOY_DOTFILES=1 ;;
            b ) INSTALL_BREW=1 ;;
            d ) INSTALL_DOWNLOADABLE=1 ;;
            f ) PREPARE_FISH=1 ;;
            c ) CARGO_BUILD_ESSENTIAL=1 ;;
            u ) CARGO_BUILD_ADDITIONAL=1 ;;
            y ) DEPLOY_DOTFILES=1 ;;
            \? ) usage ;;
        esac
    done
}

main "$@"; exit
