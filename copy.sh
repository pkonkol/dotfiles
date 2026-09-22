#!/usr/bin/env sh
# Wgrywa dotfiles do $HOME. Uruchom po KAZDEJ zmianie w repo:
#     cd ~/projects/dotfiles && ./copy.sh && exec fish
set -e

mkdir -p ~/.config/fish ~/.config/delta

# Sprzatanie po starym setupie (starship + rozbite pliki promptu).
# Wazne: plik w ~/.config/fish/functions/fish_prompt.fish MA PIERWSZENSTWO
# nad definicja w config.fish, wiec stara kopia cicho nadpisalaby nowy prompt.
rm -f  ~/.config/starship.toml
rm -f  ~/.config/fish/functions/fish_prompt.fish \
       ~/.config/fish/functions/fish_right_prompt.fish \
       ~/.config/fish/functions/fish_mode_prompt.fish \
       ~/.config/fish/functions/__pk_*.fish \
       ~/.config/fish/conf.d/pk_*.fish

cp -i  .tmux.conf              ~/
cp -i  .gitconfig              ~/
cp -ri .config/delta           ~/.config/
cp     .config/fish/config.fish ~/.config/fish/config.fish

echo "OK. Teraz: exec fish"

# Linux / homelab — odkomentuj w razie potrzeby:
#cp -i .tmux.homelab.conf ~/.tmux.conf
#cp -ri .config/nix       ~/.config/
