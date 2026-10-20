# Dotfiles. `just` bez argumentów wypisuje recepty.

default:
    @just --list

# symlinki z .dotter/global.toml do $HOME (dry-run; `just deploy --apply` wykonuje)
deploy apply="":
    dotter deploy -v {{ if apply == "--apply" { "" } else { "--dry-run" } }}

# instalacja maszyny, flagi jak w setup-mac.sh (np. just setup -b)
[macos]
setup *flags:
    bash setup-mac.sh {{ flags }}

# instalacja maszyny, flagi jak w setup.sh (np. just setup -i)
[linux]
setup *flags:
    bash setup.sh {{ flags }}

# scal dotfiles-settings.json do settings.json VS Code (z backupem)
vscode:
    .config/vscode/merge-settings.sh
