#!/usr/bin/env sh
# Wgrywa dotfiles do $HOME. Uruchom po KAZDEJ zmianie w repo:
#     cd ~/projects/dotfiles && ./copy.sh && exec fish
set -e

mkdir -p ~/.config/fish ~/.config/delta ~/.config/wezterm ~/.config/nvim

cp -i  .tmux.conf              ~/
cp -i  .gitconfig              ~/
cp -ri .config/delta           ~/.config/
cp -i    .config/fish/config.fish    ~/.config/fish/config.fish
cp -i  .config/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
cp -ri  .config/nvim/              ~/.config/nvim/     # init.lua + after/queries/

# VS Code — CELOWO bez autokopiowania: settings.json VS Code trzyma mnostwo
# rzeczy per-projekt i per-rozszerzenie, wiec nadpisanie go skryptem
# gwarantuje utrate ustawien. Scal recznie, gdy chcesz:
#     ./.config/vscode/merge-settings.sh

echo "OK. Teraz: exec fish"
echo "VS Code (opcjonalnie, scala z backupem): ./.config/vscode/merge-settings.sh"

# Linux / homelab — odkomentuj w razie potrzeby:
#cp -i .tmux.homelab.conf ~/.tmux.conf
#cp -ri .config/nix       ~/.config/
