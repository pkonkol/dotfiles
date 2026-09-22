---
tags:
  - flashcards
  - cli
created: 2026-09-22
---

# SRS — nowy setup CLI

Fiszki do pluginu **Obsidian Spaced Repetition**.
Format: `Pytanie::Odpowiedz` (jednostronna), `Pytanie:::Odpowiedz` (dwustronna),
oraz blok wieloliniowy zakonczony `?` w osobnej linii.

**Jak tego uzyc:** tiery ida od najwazniejszego. Utnij gdzie chcesz i usun reszte
(albo zakomentuj `%%...%%`). Sugerowany start: **Tier 1 + 2** (~45 fiszek,
tydzien po ~15/dzien). Tier 3 dorzuc w drugim tygodniu, Tier 4-5 tylko jesli
naprawde zaczniesz uzywac danego narzedzia.

| Tier | Co | Ile | Kiedy |
|---|---|---|---|
| 1 | Nazwy narzedzi ↔ do czego sluza | 26 | od razu — bez tego nie wiesz co masz w brew |
| 2 | Fish script: skladnia ktora ci codziennie wchodzi w droge | 24 | od razu — najwiekszy zabojca flow |
| 3 | rg / fd / fzf / zoxide — flagi ktorych uzyjesz 10x dziennie | 28 | tydzien 2 |
| 4 | eza / bat / sd / dust / procs / btm / hyperfine | 20 | tydzien 2-3 |
| 5 | Keybindingi TUI: yazi, lazygit, jless, btm, tmux, delta | 26 | gdy zaczniesz uzywac |
| 6 | mise / fisher / bass / git / tailspin / reszta | 22 | tydzien 3-4 |
| 7 | Twoj wlasny config — gdzie co siedzi | 12 | gdy cos przestanie dzialac |

---

## TIER 1 — Nazwy narzedzi ↔ do czego sluza

#flashcards/cli/nazwy

yazi:::Menedzer plikow w TUI (Rust). Nastepca rangera — startuje natychmiast, ma asynchroniczne podglady.

eza:::Nowoczesny `ls` (Rust). Kolory, ikonki, kolumna ze statusem gita, tryb drzewa.

bat:::`cat`/`less` z podswietlaniem skladni, numerami linii i integracja z gitem.

fd:::Nowoczesny `find` (Rust). Domyslnie szuka po fragmencie nazwy, respektuje `.gitignore`.

ripgrep (rg):::Nowoczesny `grep` (Rust). Rekurencyjny domyslnie, respektuje `.gitignore`, bardzo szybki.

sd:::Nowoczesny `sed` do zamiany tekstu (Rust) — normalny regex zamiast sedowej skladni.

dust:::Nowoczesny `du` (Rust) — pokazuje co zjada miejsce jako drzewo ze slupkami.

procs:::Nowoczesny `ps` (Rust) — kolory, szukanie po nazwie, tryb drzewa.

bottom (binarka `btm`):::Nowoczesny `top`/`htop` (Rust). Nastepca porzuconego `ytop`.

hyperfine:::Benchmark komend CLI (Rust). Rozgrzewka, wiele powtorzen, statystyka, porownanie A/B.

zoxide:::Skok do katalogu wg "frecency" (czestosc + swiezosc). Komenda `z`. Uczy sie z twoich `cd`.

fzf:::Generyczny interaktywny fuzzy picker. Bierze liste ze stdin, oddaje wybrany element na stdout.

tailspin (binarka `tspin`):::Koloruje DOWOLNY log w locie, bez konfiguracji (daty, poziomy, IP, UUID, sciezki, JSON).

lnav:::Nawigator po logach. Rozpoznaje formaty, scala wiele plikow po czasie, umie SQL po logach.

kubecolor:::Drop-in wrapper na `kubectl` dodajacy kolory do outputu.

grc:::Generyczny kolorowacz-wrapper (Perl) dla klasykow: `ping`, `df`, `traceroute`, `mount`, `netstat`.

delta:::Pager do `git diff` — podswietlanie skladni, side-by-side, podswietlanie zmian wewnatrz linii.

difftastic (binarka `difft`):::Diff swiadomy SKLADNI — porownuje drzewa AST, nie linie. Ignoruje przeformatowanie.

lazygit:::TUI do gita. Stage'owanie pojedynczych linii, branche, stash, rebase — wszystko z klawiatury.

xh:::Nowoczesny klient HTTP (Rust), skladnia jak HTTPie. Do klikania po REST API zamiast `curl`.

jaq:::`jq` napisany w Rust — ta sama skladnia zapytan, szybszy.

jless:::Interaktywna przegladarka JSON/YAML w terminalu. Zwijanie, szukanie, nawigacja jak w vimie.

tokei:::Liczy linie kodu w repo z podzialem na jezyki.

tealdeer:::Klient `tldr` w Rust — praktyczne przyklady uzycia komend zamiast manpage'a.

mise:::Menedzer wersji runtimeow per katalog (node/python/java/go). Zastepuje nvm + pyenv + asdf + sdkman.

uv:::Bardzo szybki menedzer pakietow i srodowisk Pythona (Rust). Zastepuje pip + venv + pip-tools.

---

## TIER 2 — Fish script: skladnia ktora codziennie wchodzi w droge

#flashcards/cli/fish

Fish: jak podstawic wynik komendy do innej komendy?::`(komenda)` — nawiasy bez dolara. `$(komenda)` tez dziala od fish 3.4, ale `()` to natywna forma.

Fish: jak ustawic zmienna lokalna / globalna / eksportowana?::`set -l x 1` (lokalna), `set -g x 1` (globalna), `set -gx x 1` (globalna + eksport do procesow potomnych).

Fish: jak USUNAC zmienna?::`set -e nazwa`

Fish: jak sprawdzic czy zmienna jest ustawiona?::`set -q nazwa` — zwraca status 0 gdy ustawiona. Uzycie: `set -q x; and echo jest`

Fish: czym jest `set -U`?::Zmienna **universal** — zapisywana na dysk, wspolna dla wszystkich sesji fisha i przetrwa restart. Latwo o niej zapomniec i potem sie dziwic; w dotfiles preferuj `-g`.

Fish: jaki jest odpowiednik `$?` z basha?::`$status` — kod wyjscia ostatniej komendy.

Fish: dlaczego nie trzeba cytowac `"$zmienna"` jak w bashu?::Bo fish **nie robi word splittingu** przy rozwijaniu zmiennych. `rm $plik` zadziala nawet gdy nazwa ma spacje.

Fish: roznica miedzy `'` a `"`?::W `"..."` zmienne i `(komenda)` sie rozwijaja. W `'...'` nic sie nie rozwija (literal).

Fish: jak dostac sie do argumentow funkcji?::`$argv` — to lista. `$argv[1]` to pierwszy. Nie ma `$1`, `$2`.

Fish: od ktorego indeksu numerowane sa listy?::Od **1**. `$lista[1]` to pierwszy element, `$lista[-1]` ostatni, `$lista[2..4]` wycinek.

Fish: jak policzyc elementy listy?::`count $lista`

Fish: skladnia `if`?
?
```fish
if test -f plik.txt
    echo jest
else if test -d plik.txt
    echo katalog
else
    echo nic
end
```
`test` (albo `[ ]`) to osobna komenda — `if` patrzy tylko na jej kod wyjscia.

Fish: skladnia `for`?
?
```fish
for plik in *.md
    echo $plik
end
```

Fish: skladnia `switch`?
?
```fish
switch $argv[1]
    case start
        echo startuje
    case stop restart
        echo stop albo restart
    case '*'
        echo cokolwiek
end
```
Wzorce w `case` musza byc cytowane gdy zawieraja `*`.

Fish: jak zdefiniowac funkcje i ja zapisac?
?
```fish
function mkcd --description 'mkdir + cd'
    mkdir -p $argv[1]; and cd $argv[1]
end
funcsave mkcd     # zapisuje do ~/.config/fish/functions/mkcd.fish
funced mkcd       # edytuje istniejaca funkcje
```

Fish: jak polaczyc komendy warunkowo?::`komenda1; and komenda2` (jak `&&`) oraz `; or` (jak `||`). `&&` i `||` tez dzialaja od fish 3.0, ale `and`/`or` to forma natywna.

Fish: co to `psub` i po co?
?
Odpowiednik bashowego `<(...)` — podstawia wyjscie komendy jako **plik**.
```fish
diff (git show HEAD:plik.txt | psub) plik.txt
```
Klasyczny zabojca flow: w fishu `<(...)` NIE dziala.

Fish: jak przekierowac stderr? Jak polaczyc stdout+stderr?
?
```fish
cmd 2> bledy.log        # sam stderr
cmd &> wszystko.log     # stdout + stderr do pliku
cmd &| grep blad        # stdout + stderr do POTOKU
cmd 2>&1 | grep blad    # to samo, dluzej
```

Fish: jak ominac alias/funkcje i wywolac prawdziwa binarke?::`command ls` — np. `command curl` gdy masz `alias curl xh`. Analogicznie `builtin` dla wbudowanych.

Fish: roznica `alias` vs `abbr`?::`abbr` rozwija sie **w miejscu** przy spacji — widzisz co naprawde odpalasz, laduje w historii w pelnej formie. `alias` to ukryta funkcja. Preferuj `abbr`.

Fish: jak robic arytmetyke?::Wbudowana komenda `math`: `math 1 + 2`, `math -s0 "floor(7/2)"`, `math "$x * 1.5"`.

Fish: do czego sluzy wbudowany `string`?
?
Cala obrobka tekstu bez odpalania sed/awk/cut:
```fish
string split ',' $csv
string match -r '(\d+)' $s
string replace -a 'a' 'b' $s
string join ' ' $lista
string trim $s
string length $s
```

Fish: skad fish automatycznie laduje funkcje?::Z `~/.config/fish/functions/NAZWA.fish` — ale **dopiero przy pierwszym wywolaniu po nazwie**. Handlery zdarzen (`--on-event`) trzeba wiec kłaść w `conf.d/`, bo ich nikt po nazwie nie wola.

Fish: czym rozni sie `conf.d/` od `config.fish`?::Pliki z `~/.config/fish/conf.d/*.fish` sa sourcowane **przed** `config.fish`, zawsze, przy kazdym starcie shella. Tam ida handlery zdarzen i modularne kawalki configu.

Fish: jak zmierzyc co spowalnia start shella?::`fish --profile-startup /tmp/p.log -i -c exit` a potem posortowac `/tmp/p.log` po drugiej kolumnie (mikrosekundy).

---

## TIER 3 — rg / fd / fzf / zoxide (uzyjesz 10x dziennie)

#flashcards/cli/szukanie

rg: jak ograniczyc szukanie do jednego typu plikow?::`rg wzor -t py` (albo `-t rust`, `-t md`). Lista typow: `rg --type-list`.

rg: jak szukac po wlasnym globie?::`rg wzor -g '*.tsx'` — mozna wielokrotnie, `-g '!*test*'` wyklucza.

rg: jak pokazac tylko NAZWY plikow z trafieniem?::`rg -l wzor` (a `--files-without-match` odwrotnie).

rg: jak dodac kontekst wokol trafienia?::`-C 3` (przed i po), `-B 3` (przed), `-A 3` (po).

rg: dlaczego rg nie znajduje pliku ktory na pewno istnieje?::Bo domyslnie respektuje `.gitignore` i pomija pliki ukryte. Obejscie: `rg --hidden --no-ignore wzor` (albo `-uu`).

rg: jak szukac dokladnego ciagu bez traktowania go jako regex?::`rg -F 'a.b*c'` (fixed string).

rg: jak szukac calego slowa, nie fragmentu?::`rg -w wzor`

rg: jak zrobic podglad zamiany bez zapisu?::`rg wzor -r 'nowe'` — pokazuje jak by wygladalo, ale **nie zapisuje plikow**. Do realnej zamiany: `sd`.

rg: jak szukac wzorca przez wiele linii?::`rg -U 'foo\n.*bar'` (`--multiline`), a `--multiline-dotall` zeby `.` lapalo nowe linie.

fd: jaka jest domyslna semantyka wzorca?::Fragment nazwy pliku, case-insensitive dopoki nie uzyjesz duzej litery (smart case). `fd cfg` znajdzie `my-config.toml`.

fd: jak filtrowac po rozszerzeniu i typie?::`fd -e rs` (rozszerzenie), `-t f` plik, `-t d` katalog, `-t l` symlink, `-t x` wykonywalny.

fd: jak zobaczyc pliki ukryte i te z .gitignore?::`fd -H` (hidden), `-I` (no-ignore), `-u` = oba naraz.

fd: jak wykonac komende na kazdym wyniku? A raz na wszystkich?::`fd -e png -x convert {} {.}.webp` — raz na plik, rownolegle. `-X` — raz, wszystkie pliki jako argumenty. `{}` sciezka, `{.}` bez rozszerzenia, `{/}` sama nazwa.

fd: jak szukac po pelnej sciezce, nie samej nazwie?::`fd --full-path 'src/.*test'`

fzf: jaka jest skladnia zapytania w fzf?
?
- `foo bar` → AND (oba fragmenty)
- `'foo` → dokladne dopasowanie (exact)
- `^foo` → prefiks, `foo$` → sufiks
- `!foo` → negacja
- `foo | bar` → OR

fzf: jak wlaczyc wybor wielu pozycji?::`fzf -m`, potem `Tab` zaznacza, `Shift-Tab` odznacza.

fzf: jak dodac podglad zawartosci?::`fzf --preview 'bat --color=always {}'` — `{}` to aktualnie podswietlona linia. `Ctrl-/` przelacza podglad.

fzf: jak uzyc wyniku fzf w fishu?::Podstawienie komendy: `nvim (fzf)` albo `cd (fd -t d | fzf)`.

fzf: co robia flagi `-1` i `-0`?::`-1` — jesli pasuje dokladnie jeden wynik, wybierz go automatycznie bez UI. `-0` — jesli nic nie pasuje, zakoncz z bledem.

fzf: jak zmienic co fzf listuje domyslnie?::Zmienna `FZF_DEFAULT_COMMAND`, np. `set -gx FZF_DEFAULT_COMMAND 'fd -t f -H'`.

zoxide: jak skoczyc do katalogu?::`z fragment` — dopasowuje po frecency. Kilka fragmentow zawezajaco: `z proj dot`.

zoxide: jak wybrac katalog interaktywnie?::`zi` — otwiera fzf z baza zoxide.

zoxide: skad zoxide bierze dane?::Uczy sie z twoich `cd`/`z`. **Na poczatku baza jest pusta** — przez pierwszy tydzien musisz swiadomie chodzic, zanim zacznie zgadywac.

zoxide: jak podejrzec i wyczyscic baze?::`zoxide query -l` (lista), `zoxide query -ls` (z punktacja), `zoxide remove /sciezka`.

fzf vs zoxide vs atuin — kto od czego?::**zoxide** = skok do katalogu (frecency). **atuin** = historia komend / Ctrl-R z sync. **fzf** = generyczny picker dla dowolnej listy. Nakladaja sie tylko interfejsem, nie zadaniem.

---

## TIER 4 — eza / bat / sd / dust / procs / btm / hyperfine

#flashcards/cli/zamienniki

eza: jak pokazac status gita przy plikach?::`eza -l --git` (a `--git-ignore` ukrywa pliki ignorowane).

eza: jak zrobic drzewo o ograniczonej glebokosci?::`eza --tree --level=2`

eza: jak posortowac po rozmiarze / dacie?::`eza -l --sort=size` albo `--sort=modified`, `-r` odwraca kolejnosc.

eza: jak zobaczyc RZECZYWISTY rozmiar katalogow?::`eza -l --total-size` — inaczej katalogi pokazuja rozmiar i-node'a, nie zawartosci.

bat: jak pokazac znaki niewidoczne (taby, CRLF, spacje na koncu)?::`bat -A plik` (`--show-all`).

bat: jak uzyc bata w skrypcie bez pagera i ozdobnikow?::`bat -pp plik` (`--plain --plain`) albo `bat --paging=never --style=plain`.

bat: jak pokazac tylko wybrane linie?::`bat -r 40:60 plik` (`--line-range`).

sd: czym rozni sie od seda?::Wzorzec to **zwykly regex** (bez sedowego escapowania), a odwolania do grup to `$1`, nie `\1`. Zamiana w miejscu domyslnie, bez `-i`.

sd: jak zrobic podglad zmian przed zapisem?::`sd -p 'stare' 'nowe' plik` (`--preview`) — pokazuje diff, nie zapisuje.

sd: jak potraktowac wzorzec doslownie, bez regexa?::`sd -s 'a.b' 'x' plik` (`--string-mode`).

sd: jak zmienic we wszystkich plikach w repo?::`fd -t f -x sd 'stare' 'nowe'` — albo `rg -l stare | xargs sd 'stare' 'nowe'`.

dust: jak ograniczyc glebokosc drzewa?::`dust -d 2`. `-n 30` zmienia liczbe wyswietlanych wpisow, `-X nazwa` wyklucza.

procs: jak znalezc proces i zobaczyc drzewo?::`procs nginx` (filtr po nazwie/porcie/PID), `procs --tree`, `procs --sortd cpu`.

procs: jak obserwowac na zywo?::`procs --watch` (albo `-W`).

btm: jak zabic proces? Jak wyszukac?::`dd` zabija podswietlony proces, `/` szuka, `?` to pelna pomoc, `e` rozwija, `f` zamraza widok.

hyperfine: jak porownac dwie komendy?::`hyperfine --warmup 3 'cmd-a' 'cmd-b'` — daje srednia, odchylenie i ile razy jedna jest szybsza.

hyperfine: jak wyczyscic stan miedzy uruchomieniami?::`hyperfine -p 'rm -rf build' 'make'` (`--prepare` — odpalane przed kazdym pomiarem, nie liczone do czasu).

hyperfine: jak przebenchmarkowac komende dla wielu wartosci parametru?::`hyperfine -L threads 1,2,4,8 'build -j{threads}'`

xh: jak wyslac POST z JSON-em?::`xh POST api.example.com/users name=piotr age:=30` — `=` to string, `:=` to surowy JSON (liczba/bool/obiekt).

jaq: jak wyciagnac pole z listy obiektow?::`cat dane.json | jaq '.items[] | .name'` — skladnia identyczna jak w `jq`.

---

## TIER 5 — Keybindingi TUI

#flashcards/cli/tui

yazi: nawigacja i wyjscie?::`hjkl` — `h` w gore katalogu, `l` wejdz/otworz. `gg`/`G` gora/dol. `q` wyjscie (z cd do biezacego katalogu jesli masz wrapper), `Q` wyjscie bez cd.

yazi: jak zaznaczyc pliki i je skopiowac/przeniesc?::`Space` zaznacza, `y` kopiuj (yank), `x` wytnij, `p` wklej, `Y`/`X` anuluj zaznaczenie do przeniesienia.

yazi: jak usunac plik?::`d` — do kosza. `D` — trwale, bez kosza.

yazi: jak stworzyc plik/katalog i zmienic nazwe?::`a` tworzy (nazwa konczaca sie `/` = katalog), `r` zmienia nazwe.

yazi: jak szukac w yazi?::`/` szuka po nazwie (fd), `s` szuka po **zawartosci** (ripgrep), `z` skacze przez zoxide.

yazi: jak odpalic komende shella na zaznaczonych plikach?::`;` — otwiera linie komendy, `$0` to zaznaczone pliki. `:` to samo ale w trybie blokujacym.

yazi: pokaz pliki ukryte / pomoc?::`.` przelacza ukryte, `~` albo `F1` otwiera pelna liste skrotow.

lazygit: jak przeskakiwac miedzy panelami?::`Tab` / `Shift-Tab`, albo cyfry `1`-`5`. `?` pokazuje skroty dla AKTUALNEGO panelu.

lazygit: jak zastage'owac plik? A pojedyncze linie?::`Space` stage'uje plik. `Enter` wchodzi w plik, tam `Space` stage'uje pojedyncza linie, `v` zaznacza blok.

lazygit: commit, amend, push?::`c` commit, `A` amend do ostatniego commita, `P` push, `p` pull.

lazygit: gdzie sa branche i stash?::Panel `3` to branche (`Space` = checkout, `n` = nowy), panel `5` to stash. `s` stashuje zmiany.

jless: nawigacja i zwijanie?::`j`/`k` gora-dol, `h` zwin, `l` rozwin, `Space` przelacz, `/` szukaj, `n`/`N` nastepne/poprzednie, `q` wyjscie.

delta: jak skakac miedzy plikami w diffie?::`n` / `N` — dziala bo masz `navigate = true` w `.gitconfig`. `delta --side-by-side` wlacza widok dwukolumnowy.

difft: jak uzyc go jako diffa dla gita ad-hoc?::`GIT_EXTERNAL_DIFF=difft git diff` — albo `difft plik-a plik-b` na wolnych plikach.

tmux: jaki masz prefiks?::`Ctrl-A` (nie domyslny `Ctrl-B`) — ustawione w twoim `.tmux.conf`.

tmux: nowe okno, przelaczanie, zmiana nazwy?::prefiks + `c` nowe okno, `n`/`p` nastepne/poprzednie, `0`-`9` po numerze, `,` zmiana nazwy, `&` zabij okno.

tmux: jak podzielic panel i przelaczac sie miedzy panelami?::prefiks + `%` pion, `"` poziom, strzalki przelaczaja, `z` zoom na panel, `x` zabij panel.

tmux: jak odpiac sie i wrocic do sesji?::prefiks + `d` odpina. `tmux ls` listuje, `tmux a -t nazwa` wraca, `tmux new -s nazwa` tworzy nazwana.

tmux: jak scrollowac/kopiowac?::prefiks + `[` wchodzi w copy mode (nawigacja jak w vimie), `Space` zaczyna zaznaczanie, `Enter` kopiuje, `q` wychodzi.

tmux: jak zainstalowac wtyczki z tpm?::prefiks + `I` (duze i) instaluje, prefiks + `U` aktualizuje.

lnav: jak przefiltrowac logi i policzyc cos SQL-em?
?
```
:filter-in ERROR          # zostaw tylko pasujace
:filter-out healthcheck   # wywal pasujace
;SELECT log_level, count(*) FROM all_logs GROUP BY 1
```
`?` to pomoc, `e`/`E` skacze do nastepnego/poprzedniego bledu.

tspin: jak ogladac log na zywo?::`tspin --follow app.log` albo po prostu `tail -f app.log | tspin`. Bez `--follow` otwiera w pagerze.

tspin: jak podkreslic wlasne slowa?::`tspin --words-red ERROR,FATAL --words-yellow WARN` albo `-e 'wlasny-regex'`.

fzf: jak przewijac podglad?::`Shift-↑`/`Shift-↓` (albo `Ctrl-/` zeby w ogole przelaczyc podglad).

btm: jak zmienic obserwowany widget?::`Tab`/strzalki miedzy widgetami, `e` rozwija podswietlony na caly ekran, `Esc` wraca.

yazi: jak zrobic zeby yazi zmienial katalog po wyjsciu?::Potrzebny wrapper — yazi zapisuje ostatni katalog do pliku przez `--cwd-file`, a funkcja shella robi potem `cd`. Sam `yazi` tego nie zrobi, bo proces potomny nie zmieni cwd rodzica.

---

## TIER 6 — mise / fisher / bass / git / reszta

#flashcards/cli/reszta

mise: jak ustawic wersje runtime globalnie i lokalnie?::`mise use -g node@22` (globalnie), `mise use node@20` w katalogu — zapisuje do `mise.toml` w repo.

mise: jak odtworzyc srodowisko z repo?::`mise install` — czyta `mise.toml` i instaluje wszystkie zadeklarowane wersje.

mise: jak odpalic cos na innej wersji bez przelaczania?::`mise exec node@18 -- node -v`

fisher: instalacja, lista, update, usuniecie wtyczki?::`fisher install autor/repo`, `fisher list`, `fisher update`, `fisher remove autor/repo`.

fisher: gdzie zapisuje liste wtyczek i czemu to wazne?::`~/.config/fish/fish_plugins` — plik tekstowy, wiec liste wtyczek mozna wersjonowac w gicie. To glowna przewaga nad recznym kopiowaniem plikow.

bass: co robi i czego NIE przeniesie?::Uruchamia kod w **bashu** i przenosi do fisha zmienne srodowiskowe, `PATH` i `cwd`. NIE przeniesie funkcji bashowych, aliasow, `shopt` ani `trap`.

bass: jak zrodlowac skrypt bashowy?::`bass source ~/.profile`. Wiele komend: `bass export X=1 ';' source setup.sh` — srednik musi byc cytowany.

git: jak wyglada twoj alias na ladny graf historii?::`git lg` = `log --all --graph --decorate --oneline`.

git: twoje skroty na status/branch/pull/push?::`git s` status, `git b` branch, `git p` = `pull --rebase`, `git pu` push.

git: co robi `git ap`?::`add -p` — interaktywne stage'owanie fragmentow (hunk po hunku).

git: dlaczego masz `push.autoSetupRemote = true`?::Pierwszy `git push` na nowej galezi sam ustawia upstream — nie trzeba `--set-upstream origin nazwa`.

git: co daje `merge.conflictstyle = zdiff3`?::W konflikcie pokazuje TRZECI blok — wspolnego przodka — wiec widac co kazda strona naprawde zmienila, a nie tylko dwie koncowe wersje.

tealdeer: jak zobaczyc przyklady uzycia komendy i zaktualizowac baze?::`tldr tar` oraz `tldr --update`.

kubecolor: co to jest z punktu widzenia uzycia?::Drop-in za `kubectl` — te same argumenty, dodane kolory. Masz na to alias, wiec `kubectl get pods` juz idzie przez niego.

kubectl + fish: dlaczego NIE wrzucac `kubectl completion fish | source` do config.fish?::Bo to fork procesu przy **kazdym starcie shella**. Zamiast tego raz: `kubectl completion fish > ~/.config/fish/completions/kubectl.fish` (powtorzyc po upgradzie).

kubectl: dlaczego Tab czasem wisi kilka sekund?::Bo completion zasobow robi **prawdziwe zapytanie do API klastra**. Jak klaster jest wolny albo niedostepny, czeka do timeoutu.

aws cli: dlaczego Tab w fishu byl wolny?::Bo `aws_completer` to skrypt Pythona — zimny start ~0.4-1 s przy **kazdym** nacisnieciu Tab.

grc: do czego go uzywac, a do czego nie?::Do komend jednorazowych (`ping`, `df`, `traceroute`, `mount`). NIE do strumienia logow na zywo — do tego `tspin`.

tokei: co robi?::Liczy linie kodu w repo z podzialem na jezyki (kod / komentarze / puste).

uv: jak zrobic srodowisko i zainstalowac paczki?::`uv venv`, potem `uv pip install -r requirements.txt`. `uv run skrypt.py` odpala w izolowanym srodowisku.

jless vs jaq — kiedy ktore?::`jaq` gdy wiesz czego szukasz i chcesz to przetworzyc w potoku. `jless` gdy nie wiesz jak wyglada JSON i chcesz go przekopac interaktywnie.

VS Code: dlaczego nie bylo ikonek Nerd Font w terminalu, skoro w WezTerm byly?::WezTerm robi automatyczny font-fallback, VS Code (xterm.js) nie — trzeba wypisac fonty jawnie: `"terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font', 'Symbols Nerd Font Mono', Menlo"`.

---

## TIER 7 — twoj wlasny config

#flashcards/cli/dotfiles

Dlaczego wyleciał starship?::Fish przerysowuje CALY prompt przy kazdej zmianie trybu vi (fish-shell#5783), a starship to fork procesu — stad kilkusekundowe lagi przy `esc` + `hjkl`.

Co daje natywny `fish_git_prompt` zamiast modulu gita w starshipie?::Jest zaimplementowany w C wewnatrz fisha — nie forkuje procesu, wiec przerysowanie promptu jest praktycznie darmowe.

Gdzie siedzi caly twoj prompt?::W JEDNYM pliku: `~/.config/fish/config.fish`. Zadnych `functions/` ani `conf.d/` — definicje funkcji w config.fish dzialaja tak samo.

Co musisz zrobic po KAZDEJ zmianie w repo dotfiles?::`cd ~/projects/dotfiles && ./copy.sh && exec fish`. Samo edytowanie repo nic nie zmienia — fish czyta `~/.config/fish/config.fish`.

Dlaczego stary `~/.config/fish/functions/fish_prompt.fish` psuje nowy prompt?::Bo plik w `functions/` ma PIERWSZENSTWO nad definicja w `config.fish` — fish autoloaduje go i cicho nadpisuje. `copy.sh` kasuje te pliki.

Co to jest "transient prompt" i po co go masz?::Po nacisnieciu Enter prompt jest przerysowywany z TLEM i dopiero wtedy komenda sie wykonuje. Podczas pisania czysto, a w scrollbacku kazda wywolana komenda ma kolorowy pasek = latwo znalezc gdzie sie zaczyna.

Jak technicznie dziala transient prompt w fishu?
?
```fish
function __pk_transient_execute
    if commandline --is-valid
        set -g __pk_transient 1
        commandline -f repaint      # przerysuj prompt (juz z tlem)
    end
    commandline -f execute          # dopiero teraz wykonaj
end
```
Plus bind na `\r` zakladany w `fish_user_key_bindings`.

Dlaczego bind Entera musi byc w `fish_user_key_bindings`?::Bo `fish_vi_key_bindings` czysci cala tablice bindow. Fish wola `fish_user_key_bindings` na koncu ustawiania trybu klawiszy — to jedyne miejsce, gdzie wlasny bind przetrwa.

Co jest po LEWEJ, a co po PRAWEJ stronie twojego promptu?::LEWO: tryb vi, ikona systemu, hostname, katalog, branch, srodowisko (venv/nix), `❯`. PRAWO: exit code, zadania w tle, czas trwania poprzedniej komendy, godzina.

Jak prompt wykrywa aktywny venv / nix shell?::Tylko po zmiennych srodowiskowych, zero forkow: `VIRTUAL_ENV` (venv/uv/poetry), `CONDA_DEFAULT_ENV`, `IN_NIX_SHELL` → `❄`, `DEVENV_ROOT`, `CONTAINER_ID` → `📦`.

Dlaczego przy `.venv` prompt pokazuje nazwe projektu, a nie `.venv`?::Bo `basename $VIRTUAL_ENV` dla `/proj/.venv` daje `.venv` — bezuzyteczne. Gdy nazwa to `.venv`/`venv`/`env`, prompt bierze katalog WYZEJ.

Kiedy pojawia sie stopka `◀`?::Gdy komenda trwala dluzej niz `pk_postexec_min` (domyslnie 1000 ms). Pokazuje czas zakonczenia, czas trwania i kod wyjscia.

Dlaczego ikona systemu liczona jest raz przy starcie, a nie w prompcie?::Bo `uname` to fork procesu — w prompcie kosztowalby przy KAZDEJ zmianie trybu vi. Liczy sie raz i siedzi w `pk_os_icon`.

Jakie sa style znacznika transientowego?::`pk_trans_style`: `rule` (linia na cala szerokosc, domyslne), `blank` (pusta linia), `bg` (tlo pod promptem — psuje czytelnosc), `none` (nic).

Dlaczego ikonka w prompcie jest przesunieta w pionie, a ikonki ezy nie?::Bo to metryki fontu. Glify z zakresu Material Design Icons (`󰀵`) maja inny baseline niz Font Awesome (``), z ktorego korzysta eza. Fix: zmien glif albo ustaw w pelni patchowany Nerd Font jako font GLOWNY zamiast fallbacku.

Jaka jedna komenda stawia macOS od zera?::`./setup-mac.sh -b -d -f -y` — brew, tpm/rustup, fish + fisher + bass + cache completions, wgranie dotfiles.

Po co sa flagi `-c` i `-u` w setup scriptach?::Opcjonalne budowanie narzedzi z `cargo` zamiast brew — gdy chcesz najnowsze wersje. Na Linuksie czesto konieczne, bo apt ma stare paczki.

Gdzie sa rzeczy linuksowe w config.fish?::Sekcja `LINUX-ONLY`, zakomentowana: `batcat`, `fdfind`, `systemctl`, `journalctl`, `xdg-open`. Debian zmienia nazwy binarek bata i fd.

Jak zmierzyc czy prompt jest szybki?::`hyperfine --warmup 3 'fish -c "fish_prompt"'` oraz `fish --profile-startup /tmp/p.log -i -c exit`.
