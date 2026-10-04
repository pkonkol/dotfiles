#!/usr/bin/env bash
set -euo pipefail

# --- Rdzen: bez tego nic nie dziala -----------------------------------------
BREW_CORE=(
    fish tmux neovim git
    coreutils          # gnu ls/date/... jako g-prefixed
    curl wget
    tree-sitter-cli
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
          | grep -o "https://[^\"]*${asset}" | head -1)"
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

install_iac_lsp() {
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform-ls
    brew install helm-ls 2>/dev/null || \
        echo "!! helm-ls nie w core — sprawdz 'brew search helm-ls' albo: go install github.com/mrjosh/helm-ls@latest"
}

main() {
    parse "$@"

    if [[ ${INSTALL_BREW:-0} -eq 1 ]]; then
        command -v brew >/dev/null 2>&1 || \
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew update
        brew install "${BREW_CORE[@]}" "${BREW_MODERN[@]}" "${BREW_COLOR[@]}" \
                     "${BREW_DEV[@]}" "${BREW_MISC[@]}" "${BREW_CLOUD[@]}"
        brew install --cask "${BREW_CASKS[@]}"
        install_mise_tools
        install_iac_lsp
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
  -l    LSP dla IaC w nvim: terraform-ls (tap HashiCorpa) + helm-ls
  -m    Zainstaluj przez mise to, co wymaga pinowania wersji (node; terraform opcjonalnie)
  -c    OPCJA DODATKOWA: zbuduj podstawowe narzedzia z cargo
  -y    Wgraj dotfiles do \$HOME
USAGE
    exit 1
}

parse() {
    [[ $# -eq 0 ]] && usage
    while getopts "abdfmlcuy" opt; do
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
