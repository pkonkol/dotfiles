# Dotfiles. `just` bez argumentów wypisuje recepty.

# os() w Termuksie to "android" (target Rusta), nie "linux"
dotter_package := if os() == "macos" { "mac" } else if os() == "android" { "termux" } else if os() == "linux" { "linux" } else { error("nieobslugiwany system: " + os()) }

# recepty pk-skills (just pk <recepta>), odpalane w pk-skills/; bez klonu modul jest pomijany
mod? pk 'pk-skills/justfile'

default:
    @just --list

# symlinki z .dotter/global.toml do $HOME (dry-run; `just deploy --apply` wykonuje)
deploy apply="":
    @test -f .dotter/local.toml || echo 'packages = ["{{ dotter_package }}"]' > .dotter/local.toml
    dotter deploy -v {{ if apply == "--apply" { "" } else { "--dry-run" } }}

# bez [macos]/[linux]: Termux nie pasuje do zadnego z tych atrybutow
# instalacja maszyny, flagi jak w setup-mac.sh / setup.sh / setup-termux.sh (np. just setup -b)
setup *flags:
    bash {{ if os() == "macos" { "setup-mac.sh" } else if os() == "android" { "setup-termux.sh" } else { "setup.sh" } }} {{ flags }}

# scal .config/vscode/settings/*.jsonc do profili VS Code (z backupem), np. just vscode dotfiles aiboostr
vscode +profiles:
    .config/vscode/merge-settings.py {{ profiles }}
