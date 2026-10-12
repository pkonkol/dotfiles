#!/usr/bin/env -S fish --no-config
# Wgrywa dotfiles z repo do $HOME. Kopiuje tylko pliki, ktore sie roznia.
# To samo co deploy.py, wersja fish do porownania. Sklejone narzedzia:
# argparse (wbudowany w fish), gum (tabelka, menu), git diff (liczenie i podglad zmian).
argparse h/help y/yes n/dry-run d/diff homelab -- $argv; or exit 2
if set -q _flag_help
    echo "Uzycie: deploy.fish [-y|--yes] [-n|--dry-run] [-d|--diff] [--homelab]"
    exit
end

set repo (path dirname (path resolve (status filename)))

# Gdzie w $HOME : skad z repo. Katalog = wszystkie pliki w srodku.
# VS Code celowo pominiety: scalaj recznie ./.config/vscode/merge-settings.sh
set mapping \
    .tmux.conf:.tmux.conf \
    .gitconfig:.gitconfig \
    .gitconfig-personal:.gitconfig-personal \
    .config/delta:.config/delta \
    .config/bat:.config/bat \
    .config/fish/config.fish:.config/fish/config.fish \
    .config/wezterm/wezterm.lua:.config/wezterm/wezterm.lua \
    .config/nvim:.config/nvim
if set -q _flag_homelab
    set mapping (string match -v '.tmux.conf:*' $mapping) .tmux.conf:.tmux.homelab.conf .config/nix:.config/nix
end

set rows       # wiersze tabelki
set todo       # pary zrodlo:cel do skopiowania
for pair in $mapping
    set dst $HOME/(string split -f1 : $pair)
    set src $repo/(string split -f2 : $pair)
    for file in (find $src -type f | sort)                  # plik albo wszystkie pliki katalogu
        set target $dst(string replace $src '' $file)
        set name (string replace $HOME '~' $target)
        if cmp -s $file $target
            set -a rows "$name,"(set_color brblack)"bez zmian"(set_color normal)",,"
            continue
        end
        set old $target; test -e $target; or set old /dev/null  # /dev/null = pliku jeszcze nie ma
        git diff --no-index --numstat $old $file | read -d \t added removed rest
        set -l status_text (set_color yellow)zmieniony
        test $old = /dev/null; and set status_text (set_color green)nowy
        set -a rows "$name,$status_text"(set_color normal)",$added,$removed"
        set -a todo $file:$target
    end
end

printf '%s\n' $rows | gum table --print --separator , --columns "Plik,Status,+,-"
for name in fish_prompt.fish fish_right_prompt.fish fish_mode_prompt.fish
    test -e ~/.config/fish/functions/$name
    and echo (set_color red)Uwaga:(set_color normal) "~/.config/fish/functions/$name cicho nadpisuje prompt z config.fish, usun go"
end

if test (count $todo) -eq 0
    echo (set_color green)"Wszystko aktualne, nic do skopiowania."(set_color normal)
    exit
end

function show_diff
    for pair in $argv
        set p (string split : $pair)
        if test -e $p[2]
            git --no-pager diff --no-index --color $p[2] $p[1]
        else
            echo (set_color green)"nowy plik: "(string replace $HOME '~' $p[2])(set_color normal)
        end
    end
end

set -q _flag_diff; and show_diff $todo
set -q _flag_dry_run; and exit

while not set -q _flag_yes
    switch (gum choose --header "Skopiowac zmienione pliki ("(count $todo)")?" tak diff nie)
        case tak
            break
        case diff
            show_diff $todo
        case '*'                                             # nie albo Esc
            exit 1
    end
end

for pair in $todo
    set p (string split : $pair)
    mkdir -p (path dirname $p[2])
    cp $p[1] $p[2]
end
echo (set_color green)"Skopiowano: "(count $todo)(set_color normal)

string match -q '*/.config/bat/*' $todo; and type -q bat; and bat cache --build   # bat czyta motywy tylko z cache
string match -q '*/.config/fish/*' $todo; and echo "Teraz: exec fish"
string match -q '*/.config/nvim/*' $todo; and echo "Nvim: zrestartuj, zeby wczytac nowy config"
