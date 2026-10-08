# ============================================================================
#  config.fish — CALY setup w jednym pliku.
#  Zasada: kazdy bajer = jedna linia. Zakomentuj -> bajer znika.
#  Prompt nie forkuje ANI RAZU (fish przerysowuje go przy kazdym ESC w vi).
#
#  Wgranie:  cd ~/projects/dotfiles && ./copy.sh && exec fish
# ============================================================================

# ============================================================================
#  USTAWIENIA PROMPTU
# ============================================================================

# --- kolory per segment (motyw bialo-zielony, jak default fisha) ---
#     Sasiadujace segmenty maja byc ROZNE — stad naprzemiennie bialy/kolor.
set -g pk_c_os     brwhite       # ikona systemu — biale jablko
set -g pk_c_host   brgreen       # hostname
set -g pk_c_cwd    white         # sciezka
set -g pk_c_git    brmagenta     # branch — rozowy, zeby odskakiwal od sciezki
set -g pk_c_env    bryellow      # venv / nix / conda
set -g pk_c_time   brblack       # zegar (drugi plan)
set -g pk_c_dur    yellow        # czas trwania
set -g pk_c_dim    brblack
set -g pk_c_rule   brblack       # linia-border po Enter
set -g pk_c_ok     brgreen       # znak zachety, status 0
set -g pk_c_err    brred         # znak zachety, status != 0
set -g pk_c_mode_n brred
set -g pk_c_mode_i brgreen
set -g pk_c_mode_r brmagenta
set -g pk_c_mode_v bryellow

# --- LEWA strona: wszystko w jednej linii, w tej kolejnosci ---
set -g pk_show_mode 1            # [N]/[I]/[V]/[R]
# Gdzie trzymac wskaznik trybu.
#   right — wszystko po prawej, LEWY prompt ma tylko '❯ ' = 2 kolumny.
#           To jedyna dzwignia na wciecie linii kontynuacji przy wklejaniu
#           wieloliniowym: fish wyrownuje je do szerokosci OSTATNIEJ linii
#           promptu (fish-shell#5156 — zaszyte w screen.cpp, bez opcji).
#   left  — tryb wraca na lewo, wciecie rosnie o dlugosc etykiety + 1.
set -g pk_mode_side right
set -g pk_show_os   1            # ikona systemu
set -g pk_show_host 1            # hostname
set -g pk_show_cwd  1            # katalog
set -g pk_show_git  1            # branch + status
set -g pk_show_env  1            # aktywny venv / nix shell / conda
set -g pk_cwd_depth 3            # ile ostatnich segmentow sciezki
set -g pk_char      '❯'
set -g pk_mode_n '[N]'
set -g pk_mode_i '[I]'
set -g pk_mode_r '[R]'
set -g pk_mode_v '[V]'

# --- PRAWA strona (fish sam ja chowa gdy komenda urosnie) ---
set -g pk_right_enabled  1
set -g pk_right_status   1       # ✘ N gdy exit code != 0
set -g pk_right_jobs     1       # ⚙ N gdy sa zadania w tle
set -g pk_right_duration 1       # ile trwala poprzednia komenda
set -g pk_right_dur_min  300     # ms; ponizej nie pokazuj
set -g pk_right_clock    1       # GODZINA
set -g pk_clock_fmt '%H:%M:%S'   # '%H:%M' krocej, '%d/%m %H:%M' z data

# --- stopka po dlugiej komendzie: '◀ 14:32:09  3.0s  exit 1' ---
set -g pk_postexec     1
set -g pk_postexec_min 1000      # ms; tylko dla komend dluzszych niz 1 s

# --- transient prompt -------------------------------------------------------
#     Po nacisnieciu ENTER prompt jest przerysowywany w wersji "z markerem"
#     i dopiero wtedy komenda sie wykonuje. Podczas pisania prompt jest czysty,
#     a w scrollbacku kazda WYWOLANA komenda ma znacznik = latwo znalezc cutoff.
set -g pk_transient_enabled 1
set -g pk_trans_style bg         # bg | rule | blank | none
#   bg    — samo TLO pod promptem (domyslne; nie rysuje zadnej kreski,
#           wiec nie kloci sie z ramkami paneli wezterma)
#   rule  — pozioma linia na cala szerokosc nad promptem
#   blank — sama pusta linia nad promptem
#   none  — nic; zostaje tylko stopka ◀ po dlugich komendach
set -g pk_rule_char '─'          # tylko dla pk_trans_style = rule

# Tlo paska. WYJATEK od zasady "tylko nazwy z palety": w srcery wszystkie
# kolory nazwane sa w intensywnosci PIERWSZEGO PLANU (nawet brblack to jasny
# cieply szary #918175), wiec jako tlo albo przepalaja, albo zabijaja kolory
# prompta. Potrzebny jest konkretny ciemny odcien, stad hex.
# Ponizsze to oficjalne szarosci srcery (xgray2/3/4).
# set -g pk_trans_bg 1A4873        # przygaszony srcery blue (#2C78BF scieniony)
#set -g pk_trans_bg 2C78BF       # pelny srcery blue — mocno, ale zabija rozowy branch
#set -g pk_trans_bg 1D3B53       # ciemniejszy granat
#set -g pk_trans_bg 3A3A3A       # xgray3 — neutralna szarosc
set -g pk_trans_bg 781814       # cieply, w strone srcery yellow (moja pochodna)

# Tlo linii, ktora WLASNIE PISZESZ. Puste = brak tla, i tak ma byc:
# podswietlanie KAZDEJ linii sprawia, ze nie widac, ktora komenda poszla.
set -g pk_live_bg ''
#set -g pk_live_bg 262626        # xgray1 — gdybys jednak chcial delikatne tlo

# --- git prompt (natywny, w C — nie forkuje) ---
set -g __fish_git_prompt_showdirtystate      1
set -g __fish_git_prompt_showuntrackedfiles  1
set -g __fish_git_prompt_showstashstate      1
set -g __fish_git_prompt_showupstream        informative
set -g __fish_git_prompt_char_dirtystate     '*'
set -g __fish_git_prompt_char_untrackedfiles '?'
set -g __fish_git_prompt_char_stashstate     '$'
set -g __fish_git_prompt_char_upstream_ahead '↑'
set -g __fish_git_prompt_char_upstream_behind '↓'

# Gdyby jednak nie pasowalo, alternatywy z Nerd Fonta (odkomentuj jedna):
#set -g pk_os_icon ''      # Font Awesome, U+F179
#set -g pk_show_os 0        # ...albo po prostu wylacz: hostname i tak odroznia maszyny
if not set -q pk_os_icon
    switch (uname -s)
        case Darwin; set -g pk_os_icon ''   # logo Apple z fontu systemowego
        case Linux
            set -l id ''
            test -r /etc/os-release; and set id (string match -r '^ID=.*' < /etc/os-release | string replace 'ID=' '' | string trim -c '"')
            switch "$id"
                case ubuntu;   set -g pk_os_icon '󰕈'
                case debian;   set -g pk_os_icon '󰣚'
                case raspbian; set -g pk_os_icon '󰐿'
                case arch;     set -g pk_os_icon '󰣇'
                case fedora;   set -g pk_os_icon '󰣛'
                case alpine;   set -g pk_os_icon ''
                case '*';      set -g pk_os_icon '󰌽'
            end
        case '*'; set -g pk_os_icon ''
    end
end

# ============================================================================
#  PROMPT
# ============================================================================

# Pusty — tryb vi rysuje fish_prompt, zeby wszystko bylo w JEDNEJ linii
# i zeby transientowe tlo objelo takze wskaznik trybu.
function fish_mode_prompt; end

function fish_prompt --description 'Minimalny: tylko znak zachety. Reszta w fish_right_prompt.'
    set -l last_status $status

    # --- tlo (transient) ---
    set -l bg
    test -n "$pk_live_bg"; and set bg --background=$pk_live_bg
    if set -q __pk_transient; and test "$__pk_transient" = 1
        set -g __pk_transient 0
        switch "$pk_trans_style"
            case rule
                set -l w $COLUMNS
                test -n "$w"; and test $w -gt 0; or set w 80
                set_color $pk_c_rule
                printf '%s' (string repeat -n $w -- $pk_rule_char)
                set_color normal
                echo
            case blank
                echo
            case bg
                set bg --background=$pk_trans_bg
        end
    end
    set -g __pk_bg $bg          # fish_right_prompt rysuje sie PO tej funkcji

    # --- tryb vi, tylko gdy go tu chcesz ---
    # KAZDY znak tutaj to jedna kolumna wciecia przy komendach wieloliniowych:
    # fish wyrownuje linie kontynuacji do szerokosci OSTATNIEJ linii promptu
    # (fish-shell#5156, zaszyte w screen.cpp, nie da sie wylaczyc).
    if test "$pk_mode_side" = left
        __pk_mode_indicator $bg
        set_color normal $bg; printf ' '
    end

    # --- znak zachety ---
    if test $last_status -eq 0
        set_color --bold $pk_c_ok $bg
    else
        set_color --bold $pk_c_err $bg
    end
    printf '%s' $pk_char
    set_color normal $bg; printf ' '
    set_color normal
end

function __pk_mode_indicator --description 'Wskaznik trybu vi; $argv to flagi tla'
    test "$pk_show_mode" = 1; or return
    contains -- "$fish_key_bindings" fish_vi_key_bindings fish_hybrid_key_bindings; or return
    switch $fish_bind_mode
        case default;             set_color --bold $pk_c_mode_n $argv; printf '%s' $pk_mode_n
        case insert;              set_color --bold $pk_c_mode_i $argv; printf '%s' $pk_mode_i
        case replace_one replace; set_color --bold $pk_c_mode_r $argv; printf '%s' $pk_mode_r
        case visual;              set_color --bold $pk_c_mode_v $argv; printf '%s' $pk_mode_v
        case '*';                 set_color --bold $pk_c_mode_n $argv; printf '[?]'
    end
end

function fish_right_prompt --description 'Cala informacja: tryb, system, host, cwd, git, env, status, zegar'
    set -l last_status $status
    test "$pk_right_enabled" = 1; or return
    set -l bg $__pk_bg
    set -l out

    # --- tryb vi ---
    if test "$pk_mode_side" != left
        set out $out (__pk_mode_indicator $bg)
    end

    # --- system ---
    test "$pk_show_os" = 1; and set out $out (set_color $pk_c_os $bg)"$pk_os_icon"

    # --- hostname ---
    test "$pk_show_host" = 1; and set out $out (set_color $pk_c_host $bg)(prompt_hostname)

    # --- katalog ---
    if test "$pk_show_cwd" = 1
        set out $out (set_color $pk_c_cwd $bg)(prompt_pwd --dir-length=0 --full-length-dirs=$pk_cwd_depth)
    end

    # --- git (natywny fish_git_prompt — w C, bez forka) ---
    if test "$pk_show_git" = 1
        set -l g (string trim -- (fish_git_prompt))
        test -n "$g"; and set out $out (set_color $pk_c_git $bg)"$g"
    end

    # --- srodowisko: TYLKO zmienne, zero podprocesow ---
    if test "$pk_show_env" = 1
        set -l e
        if set -q VIRTUAL_ENV
            set -l v (string split -r -m1 / $VIRTUAL_ENV)[-1]
            contains -- $v .venv venv env .env; and set v (string split -r -m2 / $VIRTUAL_ENV)[-2]
            set e $e $v
        end
        set -q CONDA_DEFAULT_ENV; and set e $e "conda:$CONDA_DEFAULT_ENV"
        set -q IN_NIX_SHELL;      and set e $e '❄'
        set -q DEVENV_ROOT;       and set e $e '❄devenv'
        set -q CONTAINER_ID;      and set e $e "📦$CONTAINER_ID"
        test (count $e) -gt 0; and set out $out (set_color $pk_c_env $bg)"("(string join ' ' $e)")"
    end

    # --- stan ostatniej komendy ---
    if test "$pk_right_status" = 1; and test $last_status -ne 0
        set out $out (set_color $pk_c_err $bg)"✘ $last_status"
    end
    if test "$pk_right_jobs" = 1
        set -l n (count (jobs -p))
        test $n -gt 0; and set out $out (set_color $pk_c_dim $bg)"⚙ $n"
    end
    if test "$pk_right_duration" = 1; and test "$CMD_DURATION" -ge "$pk_right_dur_min" 2>/dev/null
        set out $out (set_color $pk_c_dur $bg)(__pk_dur $CMD_DURATION)
    end
    if test "$pk_right_clock" = 1
        set out $out (set_color $pk_c_time $bg)(date "+$pk_clock_fmt")
    end

    test (count $out) -gt 0; or return
    set -l pad ''
    test (count $bg) -gt 0; and set pad ' '
    set_color normal $bg
    printf '%s%s%s' $pad (string join (set_color normal $bg)' ' $out) $pad
    set_color normal
end

function __pk_dur --description 'ms -> 1h2m / 2m5s / 4.1s / 320ms'
    set -l ms $argv[1]
    if test $ms -lt 1000
        printf '%dms' $ms
    else if test $ms -lt 60000
        printf '%.1fs' (math "$ms / 1000")
    else if test $ms -lt 3600000
        printf '%dm%ds' (math -s0 "floor($ms / 60000)") (math -s0 "floor($ms % 60000 / 1000)")
    else
        printf '%dh%dm' (math -s0 "floor($ms / 3600000)") (math -s0 "floor($ms % 3600000 / 60000)")
    end
end

# Stopka po dlugiej komendzie.
function __pk_postexec --on-event fish_postexec
    set -l st $status
    test "$pk_postexec" = 1; or return
    test "$CMD_DURATION" -ge "$pk_postexec_min" 2>/dev/null; or return
    set_color $pk_c_dim; printf '◀ %s' (date '+%H:%M:%S')
    set_color $pk_c_dur; printf '  %s' (__pk_dur $CMD_DURATION)
    test $st -ne 0; and set_color $pk_c_err; and printf '  exit %d' $st
    set_color normal; echo
end

# Transient prompt: Enter ustawia flage, przerysowuje prompt (juz z tlem),
# i dopiero potem wykonuje komende.
function __pk_transient_execute
    if commandline --is-valid
        set -g __pk_transient 1
        commandline -f repaint
    else if not commandline --paging-mode
        # niedokonczona komenda (otwarty cudzyslow, `if` bez `end`) —
        # Enter dodaje linie, nie wykonuje => zadnego paska
        set -g __pk_transient 0
    end
    commandline -f execute
end

# MUSI byc funkcja o tej nazwie: fish_vi_key_bindings czysci tablice bindow,
# a fish wola fish_user_key_bindings na koncu jej ustawiania.
function fish_user_key_bindings
    test "$pk_transient_enabled" = 1; or return
    for k in \r \n
        bind            $k __pk_transient_execute
        bind -M insert  $k __pk_transient_execute
        bind -M default $k __pk_transient_execute
    end
end

fish_vi_key_bindings
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual block
bind -M insert ctrl-f accept-autosuggestion   # po fish_vi_key_bindings, inaczej znika

# ============================================================================
#  ZACHOWANIE POWLOKI
# ============================================================================
set -g fish_greeting                            # brak powitania
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx LESS '-R -F -X'
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1            # venv rysuje nasz prompt, nie jego skrypt
set -gx MANPAGER 'nvim +Man!'                   # <- zakomentuj jesli wolisz less
set -g fish_autosuggestion_enabled 1            # szary tekst z historii; Ctrl-F przyjmuje
set -g fish_color_autosuggestion brblack
set -g fish_color_command        green
set -g fish_color_error          red

# ============================================================================
#  PATH
# ============================================================================
test -d /opt/homebrew/bin; and fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
#fish_add_path /usr/local/bin                                # macOS Intel
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin

# WezTerm trzyma CLI WEWNATRZ bundla .app i nie linkuje go do /usr/local/bin.
# Bez tego 'wezterm ls-fonts', 'wezterm cli' itd. nie istnieja w shellu.
# Bundle moze lezec w kilku miejscach zaleznie od sposobu instalacji.
for d in /Applications/WezTerm.app/Contents/MacOS \
         ~/Applications/WezTerm.app/Contents/MacOS \
         /Applications/WezTerm-nightly.app/Contents/MacOS
    test -x $d/wezterm; and fish_add_path $d; and break
end
# Nie znalazl? Zobacz gdzie faktycznie jest:
#   mdfind -name WezTerm.app
#   ls -l /Applications/WezTerm.app/Contents/MacOS/
fish_add_path ~/.docker/bin

# ============================================================================
#  INTEGRACJE — kazda to JEDEN fork przy starcie shella. Tnij bez litosci.
# ============================================================================
if status is-interactive
    type -q zoxide; and zoxide init fish | source          # z / zi
    type -q mise; and mise activate fish | source           # node/terraform/kubectl per projekt
    type -q fzf; and fzf --fish | source                   # nadpisuje Ctrl-R fisha
    #type -q direnv; and direnv hook fish | source

    # kubectl/helm/gh: NIE 'xxx completion fish | source' tutaj (fork na start).
    # Raz:  kubectl completion fish > ~/.config/fish/completions/kubectl.fish
end

# ============================================================================
#  ALIASY / ABBR   (abbr rozwija sie w miejscu — widzisz co naprawde odpalasz)
# ============================================================================

# rgrc --aliases generuje wrappery dla ~80 komend. Guard, bo bez niego
# config wywala blad przy starcie na kazdej maszynie bez rgrc (homelab, RPi).
# UWAGA: te wrappery moga opakowac tez ls/df/du — jesli nadpisza aliasy
# nizej, przenies ta linie na koniec sekcji albo wroc do listy selektywnej.
type -q rgrc; and rgrc --aliases | source

abbr -a e nvim
abbr -a vim nvim
abbr -a vi nvim

alias ls   'eza --icons --group-directories-first --sort modified'
alias ll   'eza --icons --group-directories-first --sort modified -l --git'
alias la   'eza --icons --group-directories-first --sort modified -la --git'
alias lt   'eza --icons --group-directories-first --sort modified --tree --level=2'
alias tree 'eza --icons --tree'
alias kubectl 'kubecolor'

abbr -a g git
abbr -a gs 'git status'
abbr -a gd 'git diff'
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gp 'git push'
abbr -a gl 'git pull --rebase'
abbr -a lg lazygit

abbr -a k    kubectl
abbr -a kgp  'kubectl get pods'
abbr -a kgs  'kubectl get svc'
abbr -a kgn  'kubectl get nodes'
abbr -a kd   'kubectl describe'
abbr -a kl   'kubectl logs -f'

# --- terraform / aws ---
abbr -a tf   terraform
abbr -a tfi  'terraform init'
abbr -a tfp  'terraform plan'
abbr -a tfa  'terraform apply'
abbr -a awsp 'aws --profile'
abbr -a awsw 'aws sts get-caller-identity'   # "kim jestem" — pierwsza komenda przy kazdym bledzie 403
set -gx AWS_PAGER ''                          # AWS CLI v2 domyslnie wrzuca output do pagera

# --- bashowe !! / !$ / !* (rozwijaja sie w miejscu) ---
function _last_cmd;  echo $history[1]; end
function _last_arg;  echo $history[1] | read -lat a; echo $a[-1]; end
function _last_args; echo $history[1] | read -lat a; echo $a[2..-1]; end
abbr -a '!!' --position anywhere --function _last_cmd
abbr -a '!$' --position anywhere --function _last_arg
abbr -a '!*' --position anywhere --function _last_args

# --- cheatsheet: cht tar ---
function cht
    xh -b "cht.sh/$argv[1]" User-Agent:curl
end

# ============================================================================
#  LINUX-ONLY (homelab / raspberry pi) — zakomentowane, nie usuwac
# ============================================================================
#alias bat  batcat                       # Debian/Ubuntu nazywa binarke batcat
#alias fd   fdfind                       # Debian/Ubuntu nazywa binarke fdfind
#alias open xdg-open
#abbr -a sc  systemctl
#abbr -a scu 'systemctl --user'
#abbr -a jc  'journalctl -xe'
#abbr -a jcf 'journalctl -f'
#set -gx BROWSER firefox

# ============================================================================
#  IMPORT ZE SWIATA BASHA (bass) — fisher install edc/bass
#    bass source ~/.profile
#    bass export NVM_DIR=~/.nvm ';' source $NVM_DIR/nvm.sh
#  Przenosi zmienne srodowiskowe, PATH i cwd. NIE przeniesie funkcji bashowych.
#  NIE wolaj w hot-pathcie — to fork basha.
# ============================================================================
#bass source ~/.profile
function cht
    xh -b "cht.sh/$argv[1]" User-Agent:curl
end
bind -M insert ctrl-f accept-autosuggestion

function _last_cmd; echo $history[1]; end
function _last_arg; echo $history[1] | read -lat a; echo $a[-1]; end
function _last_args; echo $history[1] | read -lat a; echo $a[2..-1]; end

abbr -a '!!' --position anywhere --function _last_cmd
abbr -a '!$' --position anywhere --function _last_arg
abbr -a '!*' --position anywhere --function _last_args

set -gx BAT_THEME srcery

