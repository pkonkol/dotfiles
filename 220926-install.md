# 2026-09-22 — nowy setup CLI

Migracja ze starship + omf + fenv/bass + ytop/ranger na czystego fisha
z natywnym promptem. Zasada: **jedno narzędzie do jednego zadania**,
**zero forków w hot-path** (prompt / start shella).

---

## 0. TL;DR — instalacja od zera

```bash
git clone <to-repo> ~/projects/dotfiles && cd ~/projects/dotfiles
./setup-mac.sh -b -d -f -y      # brew + tpm/rustup + fish + wgranie dotfiles
exec fish
```

**Po KAŻDEJ zmianie w repo** (to jest ten krok, o którym się zapomina):

```bash
cd ~/projects/dotfiles && ./copy.sh && exec fish
```

Opcjonalnie, gdy chcesz najnowsze wersje budowane u siebie:

```bash
./setup-mac.sh -c               # eza, bat, fd, rg, sd, delta, zoxide, tealdeer
./setup-mac.sh -u               # bottom, dust, procs, hyperfine, tailspin, yazi, xh, jaq, jless
```

Na Linuksie (homelab / RPi): `./setup.sh -i -d -f -c -y`.
Tam **warto** użyć cargo — apt ma przestarzałe wersje.

---

## 1. Co wyleciało i dlaczego

| Wyleciało | Powód | Zamiennik |
|---|---|---|
| **starship** | fork procesu przy **każdym** `esc` w trybie vi ([fish#5783](https://github.com/fish-shell/fish-shell/issues/5783)) — źródło 3-sekundowych lagów | jednoliniowy `fish_prompt` + `fish_git_prompt` (w C) + transient prompt |
| **oh-my-fish (omf)** | de facto martwy framework | `fisher` (jeden plik) |
| **foreign-env / fenv** | duplikat bassa — oba importują env z bashowego skryptu | `bass` |
| **ytop** | porzucony przez autora | `bottom` (`btm`) |
| **ranger** | Python, wolny start | `yazi` (Rust) |
| **skim** | duplikat fzf | `fzf` |
| **tldr** (klient Node) | wolny start | `tealdeer` (binarka nadal `tldr`) |
| **atuin** | świadomie odłożone — fishowy Ctrl-R jest dobry | (może później, dla synchronizacji) |
| `alias bat=batcat` | to alias **Debianowy**, na macOS tworzy pętlę | przeniesione do sekcji LINUX-ONLY |
| `.gitconfig: eol = crlf` | na macOS/Linux psuje pliki w working tree | `eol = lf` |

Linuksowe rzeczy **nie zostały usunięte, tylko zakomentowane** —
sekcja `10. LINUX-ONLY` w `config.fish`.

---

## 2. Ikonki w terminalu VS Code

VS Code (xterm.js) **nie robi automatycznego font-fallbacku** tak jak WezTerm.
Trzeba podać listę jawnie w `settings.json`:

```json
"terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font', 'Symbols Nerd Font Mono', Menlo",
"terminal.integrated.fontSize": 13
```

Oba fonty instaluje `setup-mac.sh -b`.

### Ikona przesunięta w pionie

To metryki fontu, nie prompt. Glify z różnych zakresów Nerd Fonta mają różne
baseline'y: zakres **Material Design Icons** (`󰀵`, U+F0035) siedzi niżej niż
**Font Awesome** (``, U+F179), z którego korzystają m.in. ikonki `eza` —
dlatego eza wygląda równo, a jabłko nie. Dwa wyjścia:

1. Zmień glif (w `config.fish` są zakomentowane alternatywy przy `pk_os_icon`).
   macOS domyślnie używa już wariantu Font Awesome.
2. Przestaw terminal na **w pełni patchowany** Nerd Font jako font główny
   (`JetBrainsMono Nerd Font`), zamiast doklejać `Symbols Only` jako fallback —
   wtedy wszystkie glify mają metryki jednego pliku fontu. W WezTerm:
   `font = wezterm.font("JetBrainsMono Nerd Font")`.

---

## 3. Prompt — jedna linia + transient

**Cały prompt siedzi w JEDNYM pliku: `.config/fish/config.fish`.**
Żadnych `functions/`, żadnych `conf.d/` — definicje funkcji w `config.fish`
działają tak samo, a jest o 7 plików mniej do pilnowania.

Podczas pisania:

```
[I] 󰀵 GU403 ~/projects/dotfiles (master *?) (myproj) ❯ kubectl get pods    14:32:05
```

Po naciśnięciu **Enter** prompt jest przerysowywany ze znacznikiem i dopiero
wtedy komenda się wykonuje — w scrollbacku każda *wywołana* komenda ma border:

```
──────────────────────────────────────────────────────────────────────────────
[I]  GU403 ~/projects/dotfiles (master *?) ❯ kubectl get pods       14:32:05
NAME          READY   STATUS
◀ 14:32:09  3.0s              <- stopka, tylko gdy komenda > 1 s
```

Style znacznika (`pk_trans_style`): `rule` (linia na całą szerokość, domyślne),
`blank` (sama pusta linia), `bg` (tło pod promptem — kolorowo, ale psuje
czytelność), `none` (nic, zostaje tylko stopka `◀`).

Lewa strona: tryb vi → system → hostname → katalog → branch → środowisko → `❯`.
Prawa strona: exit code → zadania w tle → czas trwania → **godzina**.
Fish sam chowa prawą stronę, gdy komenda urośnie.

**Segment środowiska** wykrywa (tylko po zmiennych środowiskowych, zero forków):
`VIRTUAL_ENV` (venv/uv/poetry — przy `.venv` pokazuje nazwę *projektu*, nie `.venv`),
`CONDA_DEFAULT_ENV`, `IN_NIX_SHELL` → `❄`, `DEVENV_ROOT` → `❄devenv`,
`CONTAINER_ID` → `📦` (distrobox/toolbox).

Przełączniki — sekcja **USTAWIENIA PROMPTU** na górze `config.fish`:

```fish
set -g pk_trans_style rule      # rule | blank | bg | none
set -g pk_rule_char '─'         # '━' grubsza, '╌' przerywana, '·' kropki
set -g pk_transient_enabled 0   # wyłącz transient całkiem
set -g pk_show_os 0             # segmenty osobno: mode/os/host/cwd/git/env
set -g pk_right_clock 1         # godzina po prawej
set -g pk_clock_fmt '%H:%M'     # krótszy zegar
set -g pk_postexec_min 1000     # stopka ◀ tylko dla komend > 1 s
set -g pk_c_cwd blue            # paleta per segment
```

**Jak działa transient (żeby potem nie zgłupieć):** bind na Enter ustawia flagę
`__pk_transient`, robi `commandline -f repaint` (fish rysuje prompt jeszcze raz,
tym razem z tłem) i dopiero potem `commandline -f execute`. Bind musi siedzieć
w funkcji `fish_user_key_bindings`, bo `fish_vi_key_bindings` czyści tablicę
bindów, a fish woła ten hook na samym końcu. Niedokończona komenda (otwarty
cudzysłów, `if` bez `end`) nie dostaje paska.

**Pułapka przy wgrywaniu:** plik `~/.config/fish/functions/fish_prompt.fish`
ma **pierwszeństwo** nad definicją w `config.fish`. Stara kopia cicho nadpisze
nowy prompt. `copy.sh` sam kasuje te pliki.

Zmierz prompt po zmianach:

```bash
hyperfine --warmup 3 'fish -c "fish_prompt"'
fish --profile-startup /tmp/p.log -i -c exit; sort -t' ' -k2 -rn /tmp/p.log | head
```

## 4. Kolorowanie logów — odpowiedź na pytanie o `grc`

`grc` zostaje, ale to **wrapper per komenda** (Perl, uruchamiany raz na wywołanie —
akceptowalne). Do strumieni logów jest teraz coś dużo lepszego:

### tailspin (`tspin`) — Rust, to czego szukałeś
Koloruje **dowolny** log bez konfiguracji: daty, poziomy (ERROR/WARN/INFO),
IP, UUID-y, ścieżki, liczby, JSON, quoted strings.

```bash
tspin app.log                      # otwiera w less z kolorami
tail -f app.log | tspin            # strumień na żywo
kubectl logs -f pod | tspin
journalctl -f | tspin
tspin --follow app.log
tspin -e '\d{3}ms'                 # własny highlight
tspin --words-red ERROR,FATAL --words-yellow WARN
tspin --disable-builtin-keywords    # gdy chcesz tylko własne reguły
```

### lnav — gdy log to śledztwo, nie przelot
Nawigator: rozpoznaje formaty, scala wiele plików po czasie, **SQL po logach**.
```bash
lnav /var/log/*.log
:filter-in ERROR      # w lnav
;SELECT log_level, count(*) FROM all_logs GROUP BY 1
```

### Reszta
| Do czego | Narzędzie |
|---|---|
| `kubectl` | `kubecolor` (alias już w config.fish) |
| pliki na dysku | `bat` (podświetlanie składni + numery linii) |
| JSON strumieniowo | `jaq` (jq w Rust) / `jless` (interaktywnie) |
| `ping`, `df`, `traceroute`, `mount`, `netstat` | `grc` — odkomentuj `source /opt/homebrew/etc/grc.fish` w config.fish |
| `git diff` | `delta` (już masz) + `difft` dla diffa świadomego składni |

**Wydajność:** `grc` jest OK dla komend jednorazowych, ale **nie** pchaj przez
niego strumienia na żywo — do tego `tspin`.

---

## 5. Cheatsheety

### zoxide — skok do katalogu
```bash
z dotfiles          # skacze do najczęściej/ostatnio używanego pasującego katalogu
z proj dot          # wiele fragmentów = zawężanie
z ..                # w górę
zi                  # interaktywny wybór (fzf)
zoxide query -l     # pokaż bazę
zoxide remove /path # usuń wpis
```
**Nauka:** przez pierwszy tydzień świadomie używaj `z` zamiast `cd` —
baza buduje się z twoich `cd`, więc na początku będzie pusta.

### fzf — generyczny picker
```bash
fzf                          # wybierz z stdin
vim (fzf)                    # fish: podstaw wynik
fd -t f | fzf --preview 'bat --color=always {}'
git branch | fzf | xargs git switch
kubectl get pods | fzf
```
Skróty w fzf: `Ctrl-J/K` ruch, `Tab` multi-select (`-m`), `Ctrl-/` toggle preview.
Keybindingi globalne (`Ctrl-T` pliki, `Alt-C` cd) są **zakomentowane** w config.fish —
nadpisują Ctrl-R fisha. Odkomentuj `fzf --fish | source` gdy zdecydujesz.

### eza — ls
```bash
ll                  # -l --git --icons
la                  # + ukryte
lt                  # drzewo, 2 poziomy
eza -l --sort=size --reverse
eza -l --total-size          # rzeczywisty rozmiar katalogów
eza --git-ignore
```

### bat / fd / rg / sd
```bash
bat file.py                 bat -A file      # pokaż znaki niewidoczne
fd nazwa                    fd -e rs -x wc -l    # exec na wynikach
rg 'wzor' -t py             rg -l wzor       # tylko nazwy plików
rg --hidden --no-ignore wzor
sd 'stare' 'nowe' file.txt  # UWAGA: zwykłe stringi, nie regex-escapes jak sed
sd -p 'a' 'b' f.txt         # -p = dry run (preview)
```

### bottom / dust / procs / hyperfine
```bash
btm                 # top; 'dd' zabija proces, '?' pomoc
dust -d 2           # du, 2 poziomy
procs nginx         # ps z filtrem
procs --tree
hyperfine 'cmd1' 'cmd2' --warmup 3
```

### yazi — menedżer plików
```bash
yy                  # (dodaj funkcję shell-wrapper jeśli chcesz cd-on-exit)
```
W środku: `hjkl` nawigacja, `Space` zaznacz, `y`/`x`/`p` kopiuj/wytnij/wklej,
`d` do kosza, `a` nowy plik, `.` ukryte, `z` zoxide, `/` szukaj, `q` wyjście,
`Tab` podgląd, `F1` pełna pomoc.

### mise — wersje runtimeów (zastępuje nvm/pyenv/asdf/sdkman)
```bash
mise use -g node@22            # globalnie
mise use java@temurin-21       # w tym katalogu -> zapisuje .mise.toml
mise ls                        # co zainstalowane
mise install                   # zainstaluj wg .mise.toml w repo
mise exec node@20 -- node -v
```
Aktywacja jest **zakomentowana** w config.fish — odkomentuj gdy zaczniesz używać.

### lazygit / delta / difftastic
```bash
lg                  # lazygit; w środku: Space stage, c commit, P push, ? pomoc
difft a.py b.py
GIT_EXTERNAL_DIFF=difft git diff
```

### xh / jaq / jless
```bash
xh :8080/api/health
xh POST api.example.com/x name=foo n:=3
xh -d url                      # download
cat big.json | jaq '.items[] | .name'
jless big.json                 # interaktywnie: hjkl, / szukaj, Space fold
```

### tealdeer
```bash
tldr tar
tldr --update
```

---

## 6. fisher — menedżer wtyczek fisha

Jeden plik (`functions/fisher.fish`), bez frameworka. Instaluje pliki wtyczki
do `~/.config/fish/{functions,completions,conf.d}` i zapisuje listę w
`~/.config/fish/fish_plugins` — czyli plugin lista jest wersjonowalna w gicie.

```bash
fisher install edc/bass
fisher list                    # <- to o co pytałeś
fisher list bass               # czy zainstalowany
fisher update                  # wszystko
fisher update edc/bass
fisher remove edc/bass
```

**Warte uwagi:** `edc/bass`, `patrickf1/fzf.fish` (świetna integracja fzf),
`jorgebucaran/autopair.fish`, `gazorby/fish-abbreviation-tips`.
Na razie instalujemy **tylko bass** — minimalizm.

---

## 7. bass — odpowiedź na twoje pytanie

**Tak, ale z zastrzeżeniem.** `bass` uruchamia podany kod **w bashu**,
a potem przenosi z powrotem do fisha: zmienne środowiskowe, `PATH` i `cwd`.

```fish
bass source ~/.profile
bass source /opt/ros/humble/setup.bash
bass export NVM_DIR=~/.nvm ';' source $NVM_DIR/nvm.sh ';' nvm use 18
bass 'eval $(ssh-agent -s)'
```

Czego **nie** przeniesie: funkcji bashowych, aliasów bashowych, `shopt`,
pułapek (`trap`), i wszystkiego co nie jest zmienną środowiskową.
Więc szablon typu "eksportuje zmienne i dopisuje do PATH" → zadziała.
Szablon który definiuje funkcję `nvm()` → nie zadziała (stąd `mise`).

**Nie wołaj bassa w hot-path** (prompt, każdy start shella) — to fork basha,
kilkadziesiąt ms. Do stałych zmiennych przepisz raz na fisha:

```fish
# ~/.profile:  export FOO=bar ; export PATH="$HOME/bin:$PATH"
# fish:
set -gx FOO bar
fish_add_path ~/bin
```

---

## 8. Naprawa lagów: kubectl i awscli

To **nie był** prompt — to completions.

**kubectl.** Nie wołaj `kubectl completion fish | source` w `config.fish`
(fork przy każdym starcie shella). Zamiast tego raz, do pliku:

```bash
kubectl completion fish > ~/.config/fish/completions/kubectl.fish
```
(powtórz po `brew upgrade kubectl`; `setup-mac.sh -f` robi to automatycznie).

Completion zasobów robi **prawdziwe zapytania do API klastra** — jeśli klaster
jest wolny/niedostępny, Tab wisi do timeoutu. Ogranicz to:

```fish
set -gx KUBECTL_EXTERNAL_DIFF 'difft'
# i w ~/.kube/config ustaw rozsądny timeout, albo:
abbr -a k 'kubectl --request-timeout=5s'
```

**aws.** Fishowy completer odpala `aws_completer` (Python, cold start ~0.4–1 s
**na każdy Tab**). Jeśli masz go w configu — usuń. Natywne completions fisha
dla `aws` są wystarczające. Jeśli musisz mieć pełne:

```bash
# rozważ aws-cli v2 + cache, albo po prostu zrezygnuj z completions dla aws
```

**Bonus — zawieszki przy Tab na macOS.** Fish przy opisach komend woła
`apropos`/`man -k`. Z zimnym cache man-db to potrafi zamrozić terminal.
Rozgrzej raz: `sudo /usr/libexec/makewhatis` (albo `sudo makewhatis`).

---

## 9. Plan na najbliższe tygodnie

- [x] **T1** — czysty fish, prompt, separator, ikonki w VS Code, brew one-shot
- [ ] **T2** — zoxide + fzf na poważnie (wyrobić nawyk `z`), yazi zamiast rangera
- [ ] **T3** — kubectl/kubecolor/completions cache, lazygit, tailspin w codziennym flow
- [ ] **T4** — opcjonalnie: mise, atuin (jeśli chcesz sync), AI pod keybind

### AI w CLI — na razie świadomie nic
Fishowe **autosuggestions** (szary tekst, `Ctrl-F` / `→` przyjmuje,
`Alt-→` jedno słowo) to ta sama ergonomia co inline completion w VS Code,
tylko z twojej historii — zero latencji, zero sieci.
Gdy zechcesz prawdziwe AI, podepnij **on-demand** pod keybind
(`aichat`, `gh copilot suggest`, Claude Code) zamiast daemona w tle
(Amazon Q / Warp — dokładnie ten rodzaj rzeczy, który tniemy).
