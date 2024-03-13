#!/usr/bin/bash
sudo apt install -y build-essential whois neovim syncthing tmux ranger fish tldr nmap masscan python-is-python3 exa bat ripgrep fd-find zoxide grc sd
git clone https://github.com/pkonkol/dotfiles.git

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 2137
sudo ufw enable
systemctl enable user@syncthing
systemctl start user@syncthing

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
curl -sS https://starship.rs/install.sh | sh

chsh -s $(which fish)
tldr -u
starship preset gruvbox-rainbow -o ~/.config/starship.toml
omf install grc bass foreign-env 

source "$HOME/cargo/.env"
cargo install skim atuin 
# cargo install ytop bandwhich du-dust procs
