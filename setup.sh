#!/usr/bin/env bash
# ============================================================================
#  setup.sh — bootstrap Linux (homelab / raspberry pi)
#  Uwaga: repozytoria dystrybucji czesto maja STARE wersje tych narzedzi.
#         Tam gdzie to wazne — buduj z cargo (-c / -u).
#         Debian/Ubuntu zmienia nazwy binarek: bat->batcat, fd->fdfind.
#         Aliasy na to sa zakomentowane w config.fish (sekcja LINUX-ONLY).
# ============================================================================
set -euo pipefail

APT_CORE=(build-essential fish tmux neovim git curl wget unzip)
APT_MODERN=(eza bat fd-find ripgrep zoxide fzf duf tealdeer jq)
APT_COLOR=(grc lnav)
APT_DEV=(shellcheck direnv python3 python3-venv)
APT_MISC=(whois nmap syncthing translate-shell)

main() {
    parse "$@"

    if [[ ${INSTALL_APT:-0} -eq 1 ]]; then
        sudo apt update
        sudo apt install -y "${APT_CORE[@]}" "${APT_MODERN[@]}" "${APT_COLOR[@]}" \
                            "${APT_DEV[@]}" "${APT_MISC[@]}"
    fi

    if [[ ${INSTALL_DOWNLOADABLE:-0} -eq 1 ]]; then
        # Nerd Font — na serwerze bez GUI zwykle zbedny, ale tmux/eza z ikonkami tak
        wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip"
        mkdir -p ~/.local/share/fonts
        unzip -o -d ~/.local/share/fonts NerdFontsSymbolsOnly.zip
        fc-cache -fv
        [[ -d ~/.tmux/plugins/tpm ]] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        command -v rustup >/dev/null 2>&1 || \
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # mise — wersje runtimeow (w apt go nie ma)
        curl https://mise.run | sh
    fi

    if [[ ${PREPARE_FISH:-0} -eq 1 ]]; then
        grep -qxF "$(command -v fish)" /etc/shells || command -v fish | sudo tee -a /etc/shells
        chsh -s "$(command -v fish)"
        fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
        fish -c 'fisher install edc/bass'
        tldr --update || true
        mkdir -p ~/.config/fish/completions
        command -v kubectl >/dev/null && kubectl completion fish > ~/.config/fish/completions/kubectl.fish
    fi

    # --- cargo: na Linuksie czesto NIE opcja, tylko koniecznosc (stare apt) ---
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

    if [[ ${SETUP_UFW:-0} -eq 1 ]]; then
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
        sudo ufw allow syncthing
        sudo ufw enable
        systemctl enable user@syncthing
        systemctl start  user@syncthing
    fi
}

usage() {
    cat <<USAGE
Usage: $0 [-a] [-i] [-d] [-f] [-c] [-u] [-w] [-y]
  -a    Wszystko
  -i    Pakiety apt
  -d    Pobierane rzeczy (fonty, tpm, rustup, mise)
  -f    Przygotuj fisha (chsh, fisher, bass, cache completions)
  -c    Zbuduj podstawowe narzedzia z cargo (zalecane: apt ma stare wersje)
  -u    Zbuduj dodatkowe narzedzia z cargo
  -w    Skonfiguruj UFW
  -y    Wgraj dotfiles do \$HOME
USAGE
    exit 1
}

parse() {
    [[ $# -eq 0 ]] && usage
    while getopts "aidfcuwy" opt; do
        case ${opt} in
            a ) INSTALL_APT=1; INSTALL_DOWNLOADABLE=1; PREPARE_FISH=1; CARGO_BUILD_ESSENTIAL=1; SETUP_UFW=1; DEPLOY_DOTFILES=1 ;;
            i ) INSTALL_APT=1 ;;
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
