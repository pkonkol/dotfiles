#!/usr/bin/env bash
main() {
    parse "$@"

    if [[ $INSTALL_BREW -eq 1 ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew install coreutils whois neovim syncthing tmux ranger fish tldr nmap masscan python3 bat ripgrep fd zoxide grc translate-shell fzf shellcheck
    fi
    if [[ $INSTALL_DOWNLOADABLE -eq 1 ]]; then
        brew install --cask font-symbols-only-nerd-font
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
        curl -sS https://starship.rs/install.sh | sh
    fi
    if [[ $PREPARE_FISH -eq 1 ]]; then
        chsh -s $(which fish)
        tldr -u
        fish -c 'omf install grc bass foreign-env'
    fi
    if [[ $CARGO_BUILD_ESSENTIAL -eq 1 ]]; then
        source "$HOME/.cargo/env"
        cargo install eza atuin git-delta cargo-cache
    fi
    if [[ $CARGO_BUILD_ADDITIONAL -eq 1 ]]; then
        source "$HOME/.cargo/env"
        cargo install ytop bandwhich du-dust procs skim
    fi
    if [[ $DEPLOY_DOTFILES -eq 1 ]]; then
        ./copy.sh
    fi
}

usage() {
    echo "Usage: $0 [-a] [-b] [-d] [-f] [-c] [-u] [-y]"
    echo "Options:"
    echo "  -a    Run all commands"
    echo "  -b    Install Homebrew packages"
    echo "  -d    Install downloadable packages"
    echo "  -f    Prepare fish shell"
    echo "  -c    Build essential cargo packages"
    echo "  -u    Build additional cargo packages"
    echo "  -y    Deploy dotfiles"
    exit 1
}

parse() {
    if [[ $# -eq 0 ]]; then
        usage; exit
    fi
    while getopts "abdfcuy" opt; do
        case ${opt} in
            a ) INSTALL_BREW=1; INSTALL_DOWNLOADABLE=1; PREPARE_FISH=1; CARGO_BUILD_ESSENTIAL=1; CARGO_BUILD_ADDITIONAL=1; DEPLOY_DOTFILES=1 ;;
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