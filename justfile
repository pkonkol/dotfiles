# Dotfiles. `just` bez argumentów wypisuje recepty.

dotter_package := if env("TERMUX_VERSION", "") != "" { "termux" } else if os() == "macos" { "mac" } else if os() == "linux" { "linux" } else { error("nieobslugiwany system: " + os()) }
# dotter_package := if os() == "macos" { "mac" } else if os() == "linux" { "linux" } else { error("nieobslugiwany system: " + os()) }

default:
    @just --list

# symlinki z .dotter/global.toml do $HOME (dry-run; `just deploy --apply` wykonuje)
deploy apply="":
    @test -f .dotter/local.toml || echo 'packages = ["{{ dotter_package }}"]' > .dotter/local.toml
    dotter deploy -v {{ if apply == "--apply" { "" } else { "--dry-run" } }}

# instalacja maszyny, flagi jak w setup-mac.sh (np. just setup -b)
[macos]
setup *flags:
    bash setup-mac.sh {{ flags }}

# instalacja maszyny, flagi jak w setup.sh / setup-termux.sh (np. just setup -i)
# Termux to dla justa tez "linux", wiec rozroznia go TERMUX_VERSION
[linux]
setup *flags:
    bash {{ if env("TERMUX_VERSION", "") != "" { "setup-termux.sh" } else { "setup.sh" } }} {{ flags }}

# scal .config/vscode/settings/*.jsonc do profili VS Code (z backupem), np. just vscode dotfiles aiboostr
vscode +profiles:
    .config/vscode/merge-settings.py {{ profiles }}
