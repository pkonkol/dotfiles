#!/usr/bin/bash
sudo apt install -y build-essential whois neovim syncthing tmux ranger fish tldr nmap masscan python-is-python3 bat ripgrep fd-find zoxide grc sd translate-shell
#git clone https://github.com/pkonkol/dotfiles.git

#sudo ufw default deny incoming
#sudo ufw default allow outgoing
#sudo ufw allow ssh
#sudo ufw allow syncthing
#sudo ufw enable
#systemctl enable user@syncthing
#systemctl start user@syncthing

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
curl -sS https://starship.rs/install.sh | sh

chsh -s $(which fish)
tldr -u
fish -c 'omf install grc bass foreign-env'

source "$HOME/.cargo/.env"
cargo install eza atuin git-delta cargo-cache
# cargo install ytop bandwhich du-dust procs skim 
