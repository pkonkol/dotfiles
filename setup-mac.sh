#!/usr/bin/env bash
set -euo pipefail

# --- Rdzen: bez tego nic nie dziala -----------------------------------------
BREW_CORE=(
    fish tmux neovim git
    coreutils          # gnu ls/date/... jako g-prefixed
    curl wget
    tree-sitter-cli
    dotter             # symlinki dotfiles (-y)
    just               # justfile w repo: just deploy / setup / vscode
)

# --- zsh: pluginy, ktore .zshrc wczytuje z /opt/homebrew/share ---------------
BREW_ZSH=(
    powerlevel10k
    zsh-vi-mode
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search   # strzalka w gore / k szuka fragmentu, jak fish
    zsh-you-should-use             # przypomina alias, gdy wpiszesz pelna komende
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
    # grc                # kolorowacz-wrapper dla ping/df/traceroute (Python)
    lnav               # nawigator po logach z SQL
    difftastic         # diff swiadomy skladni (binarka: difft)
)

# --- Cloud / k8s / IaC -------------------------------------------------------
#  ZASADA: przez mise ida TYLKO te narzedzia, ktorych wersja jest sprzezona
#  z czyms zewnetrznym (state, lockfile, wersja klastra). Cala reszta z brew.
#  Ponizsze nie maja takiego sprzezenia — wersja nie ma znaczenia, wiec brew.
BREW_CLOUD=(
    awscli             # v2; backward-compatible, chcesz najnowsze. Ma EKS wbudowane.
    helm
    kustomize          # kubectl ma to wbudowane jako 'apply -k'; osobna binarka do 'build'
    k9s                # TUI do klastra
    kubectx            # kubectx / kubens
    kubecolor            # JEDNO zrodlo prawdy — NIE bierz go rownolegle z mise
    #stern             # logi z wielu podow naraz

    k3d                # k3s w dockerze: najszybszy, ma ingress + LoadBalancer z pudelka
    kind               # czysty upstream k8s w dockerze; tego uzywa wiekszosc CI
    minikube           # najstarszy, najwiecej addonow (dashboard, ingress, registry)
    #docker-desktop # na razie wgrane przez .dmg
)

# --- Serwery LSP dla nvim (wlaczone w .config/nvim/init.lua) -----------------
BREW_LSP=(
    lua-language-server           # lua_ls
    bash-language-server          # bashls          (npm)
    fish-lsp                      # fish_lsp        (npm)
    yaml-language-server          # yamlls          (npm)
    helm-ls                       # helm_ls
    markdown-oxide                # markdown_oxide
    vscode-langservers-extracted  # jsonls          (npm)
    taplo                         # taplo
    dockerfile-language-server    # dockerls        (npm)
    typescript-language-server    # ts_ls           (npm, + typescript)
    #terraform-ls                  # terraformls
)

# --- Dev / wersje runtimeow --------------------------------------------------
BREW_DEV=(
    git-delta lazygit gh
    mise               # wersje node/python/java/go per katalog (zastepuje nvm/pyenv/asdf/sdkman)
    uv
    shellcheck
    direnv
)

# --- Sieciowe / reszta -------------------------------------------------------
BREW_MISC=(
    ffmpeg poppler sevenzip
    whois nmap syncthing translate-shell imagemagick
)

BREW_CASKS=(
    font-jetbrains-mono-nerd-font
)

install_ioskeley() {
    local repo="ahatem/IoskeleyMono"
    local asset="IoskeleyMono-Term-NerdFont.zip"
    local dest="$HOME/Library/Fonts"
    local tmp; tmp="$(mktemp -d)"

    brew install --cask font-ioskeley-mono 2>/dev/null || true

    echo "==> Ioskeley Mono Term Nerd Font"
    local url
    url="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
          | grep -o "https://[^\"]*${asset}" | head -1 || true)"
    if [[ -z "$url" ]]; then
        echo "    !! nie znalazlem ${asset} w najnowszym release"
        echo "    !! pobierz recznie: https://github.com/${repo}/releases"
        rm -rf "$tmp"; return 0
    fi

    curl -fsSL -o "${tmp}/${asset}" "$url"
    unzip -qo "${tmp}/${asset}" -d "${tmp}/f"
    mkdir -p "$dest"
    find "${tmp}/f" -name '*.ttf' -o -name '*.otf' | while read -r f; do
        cp -f "$f" "$dest/"
    done
    rm -rf "$tmp"
}

install_mise_tools() {
    command -v mise >/dev/null || { echo "!! brak mise (brew install mise)"; return 1; }
    mise use -g node@lts
}

# Skille Claude Code: plugin "pk" -> /pk:<skill>. Zrodlo w dotfiles/pk-skills (.gitignore).
# Symlinki ~/.claude/skills/pk i ~/.claude/rules/pk-*.md robi dotter (-y, pakiet mac).
# Prywatne repo: git zapyta o login i token (credential.helper=store).
install_pk_skills() {
    [[ -d pk-skills ]] || git clone https://github.com/pkonkol/pk-skills.git pk-skills
}

main() {
    parse "$@"

    if [[ ${INSTALL_BREW:-0} -eq 1 ]]; then
        command -v brew >/dev/null 2>&1 || \
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew update
        # || — jeden zepsuty pakiet nie ubija calego skryptu; bledy widac wyzej
        brew install "${BREW_CORE[@]}" "${BREW_ZSH[@]}" "${BREW_MODERN[@]}" "${BREW_COLOR[@]}" \
                     "${BREW_DEV[@]}" "${BREW_MISC[@]}" "${BREW_CLOUD[@]}" \
                     "${BREW_LSP[@]}" || echo "!! brew: czesc pakietow sie nie zainstalowala"
        brew install --cask "${BREW_CASKS[@]}" || echo "!! brew cask: blad"
        install_mise_tools
    fi

    if [[ ${INSTALL_DOWNLOADABLE:-0} -eq 1 ]]; then
        install_ioskeley
        # tmux plugin manager
        [[ -d ~/.tmux/plugins/tpm ]] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        # rust toolchain — potrzebny tylko dla -c / -u ponizej
        command -v rustup >/dev/null 2>&1 || \
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	# TODO lepsze miejsce, najlepiej w brew ale to ma dependencje na ten step totaj. Nie zapomne, moze tak wisiec na razie.
        cargo install rgrc
        install_pk_skills || echo "!! pk-skills: nie wgrane"
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
    if [[ ${MISE_TOOLS:-0} -eq 1 ]]; then
        install_mise_tools
    fi

    if [[ ${CARGO_BUILD:-0} -eq 1 ]]; then
        source "$HOME/.cargo/env"
	# essential
        cargo install eza bat fd-find ripgrep sd git-delta zoxide tealdeer cargo-cache
	# additional
        cargo install bottom du-dust procs hyperfine tailspin yazi-fm yazi-cli xh jaq jless tokei bandwhich
    fi

    if [[ ${DEPLOY_DOTFILES:-0} -eq 1 ]]; then
        [[ -f .dotter/local.toml ]] || echo 'packages = ["mac"]' > .dotter/local.toml
        dotter deploy
    fi
}

usage() {
    cat <<USAGE
Usage: $0 [-a] [-b] [-d] [-f] [-m] [-c] [-y]
  -a    Wszystko
  -b    Pakiety Homebrew (to jest jedyne co realnie potrzebne na macOS)
  -d    Pobierane rzeczy (font, tpm, rustup, skille Claude /pk:)
  -f    Przygotuj fisha (chsh, fisher, bass, cache completions)
  -m    Zainstaluj przez mise to, co wymaga pinowania wersji (node; terraform opcjonalnie)
  -c    OPCJA DODATKOWA: zbuduj podstawowe narzedzia z cargo
  -y    Podlinkuj dotfiles do \$HOME (dotter, pakiet mac)
USAGE
    exit 1
}

parse() {
    [[ $# -eq 0 ]] && usage
    while getopts "abdfmcy" opt; do
        case ${opt} in
            a ) INSTALL_BREW=1; INSTALL_DOWNLOADABLE=1; PREPARE_FISH=1; MISE_TOOLS=1; DEPLOY_DOTFILES=1 ;;
            b ) INSTALL_BREW=1 ;;
            d ) INSTALL_DOWNLOADABLE=1 ;;
            f ) PREPARE_FISH=1 ;;
            m ) MISE_TOOLS=1 ;;
            c ) CARGO_BUILD=1 ;;
            y ) DEPLOY_DOTFILES=1 ;;
            \? ) usage ;;
        esac
    done
}

main "$@"; exit
