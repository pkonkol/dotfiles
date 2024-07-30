#!/usr/bin/bash
main() {
    parse $@

    if [[ $INSTALL_APT -eq 1 ]]; then
        sudo apt install -y build-essential whois neovim syncthing tmux ranger fish tldr nmap masscan python-is-python3 bat ripgrep fd-find zoxide grc translate-shell fzf shellcheck
    fi
    if [[ $INSTALL_DOWNLOADABLE -eq 1 ]]; then
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
    if [[ $SETUP_UFW -eq 1 ]]; then
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
        sudo ufw allow syncthing
        sudo ufw enable
        systemctl enable user@syncthing
        systemctl start user@syncthing
    fi
}

usage() {
    echo "Usage: $0 [-a] [-i] [-d] [-f] [-c] [-u] [y]"
    echo "Options:"
    echo "  -a    Run all commands"
    echo "  -i    Install apt packages"
    echo "  -d    Install downloadable packaes"
    echo "  -f    Prepare fish shell"
    echo "  -c    Build essential cargo packages"
    echo "  -u    Build additional cargo packaes"
    echo "  -w    Set up UFW"
    echo "  -y    Deploy dotfiles"
    exit 1
}

parse() {
    if [[ $# -eq 0 ]]; then
        usage; exit
    fi
    while getopts "aidfcuwy" opt; do
        case ${opt} in
            a ) INSTALL_APT=1; INSTALL_DOWNLOADABLE=1; PREPARE_FISH=1; CARGO_BUILD_ESSENTIAL=1; CARGO_BUILD_ADDITIONAL=1; SETUP_UFW=1;DEPLOY_DOTFILES=1 ;;
            i ) INSTALL_APT=1 && echo "h2" ;;
            d ) INSTALL_DOWNLOADABLE=1 ;;
            f ) PREPARE_FISH=1 ;;
            c ) CARGO_BUILD_ESSENTIAL=1 ;;
            u ) CARGO_BUILD_ADDITIONAL=1 ;;
            w ) SETUP_UFW=1 ;;
            y ) DEPLOY_DOTFILES=1 ;;
            \? ) usage ;;
        esac
    done
}

main "$@"; exit
