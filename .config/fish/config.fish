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
set -g pk_trans_style rule       # rule | blank | bg | none
#   rule  — pozioma linia na CALA szerokosc nad promptem (domyslne, czytelne)
#   blank — sama pusta linia nad promptem (najciszej)
#   bg    — tlo pod promptem (kolorowo, ale psuje czytelnosc — odradzam)
#   none  — nic; zostaje tylko stopka ◀ po dlugich komendach
set -g pk_rule_char '─'          # '━' grubsza, '╌' przerywana, '·' kropki
set -g pk_trans_bg brblack       # uzywane tylko przy pk_trans_style = bg
#   Celowo nazwa z palety terminala, nie '#005f5f': kolory nazwane bierze
#   sie z motywu terminala, wiec dzialaja tak samo w WezTerm, VS Code, tmux
#   i przez ssh na 256-kolorowym TERM-ie. Hex wymaga truecolor.

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

function fish_prompt --description 'Jedna linia; po ENTER przerysowana z tlem'
    set -l last_status $status

    # Czy to przerysowanie "po Enter"? Wtedy dorysuj marker nad promptem.
    set -l bg
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

    # 1. tryb vi
    if test "$pk_show_mode" = 1; and contains -- "$fish_key_bindings" fish_vi_key_bindings fish_hybrid_key_bindings
        switch $fish_bind_mode
            case default;             set_color --bold $pk_c_mode_n $bg; printf '%s' $pk_mode_n
            case insert;              set_color --bold $pk_c_mode_i $bg; printf '%s' $pk_mode_i
            case replace_one replace; set_color --bold $pk_c_mode_r $bg; printf '%s' $pk_mode_r
            case visual;              set_color --bold $pk_c_mode_v $bg; printf '%s' $pk_mode_v
            case '*';                 set_color --bold $pk_c_mode_n $bg; printf '[?]'
        end
        set_color normal $bg; printf ' '
    end

    # 2. system
    test "$pk_show_os" = 1; and set_color $pk_c_os $bg; and printf '%s ' $pk_os_icon

    # 3. hostname
    test "$pk_show_host" = 1; and set_color $pk_c_host $bg; and printf '%s ' (prompt_hostname)

    # 4. katalog
    if test "$pk_show_cwd" = 1
        set_color $pk_c_cwd $bg
        printf '%s ' (prompt_pwd --dir-length=0 --full-length-dirs=$pk_cwd_depth)
    end

    # 5. git (natywny fish_git_prompt — implementacja w C, bez forka)
    if test "$pk_show_git" = 1
        set -l g (string trim -- (fish_git_prompt))
        test -n "$g"; and set_color $pk_c_git $bg; and printf '%s ' $g
    end

    # 6. srodowisko — TYLKO zmienne srodowiskowe, zero podprocesow
    if test "$pk_show_env" = 1
        set -l e
        if set -q VIRTUAL_ENV
            # '.venv' / 'venv' nic nie mowi — pokaz nazwe PROJEKTU
            set -l v (string split -r -m1 / $VIRTUAL_ENV)[-1]
            if contains -- $v .venv venv env .env
                set v (string split -r -m2 / $VIRTUAL_ENV)[-2]
            end
            set e $e $v                                                         # venv / uv / poetry
        end
        set -q CONDA_DEFAULT_ENV; and set e $e "conda:$CONDA_DEFAULT_ENV"
        set -q IN_NIX_SHELL;      and set e $e '❄'                              # nix-shell
        set -q DEVENV_ROOT;       and set e $e '❄devenv'
        set -q CONTAINER_ID;      and set e $e "📦$CONTAINER_ID"                # distrobox/toolbox
        if test (count $e) -gt 0
            set_color $pk_c_env $bg; printf '(%s) ' (string join ' ' $e)
        end
    end

    # 7. znak zachety
    if test $last_status -eq 0
        set_color --bold $pk_c_ok $bg
    else
        set_color --bold $pk_c_err $bg
    end
    printf '%s' $pk_char
    set_color normal $bg; printf ' '
    set_color normal
end

function fish_right_prompt --description 'Godzina, czas trwania, exit code, joby'
    set -l last_status $status
    test "$pk_right_enabled" = 1; or return
    set -l out

    if test "$pk_right_status" = 1; and test $last_status -ne 0
        set out $out (set_color $pk_c_err)"✘ $last_status"(set_color normal)
    end
    if test "$pk_right_jobs" = 1
        set -l n (count (jobs -p))
        test $n -gt 0; and set out $out (set_color $pk_c_dim)"⚙ $n"(set_color normal)
    end
    if test "$pk_right_duration" = 1; and test "$CMD_DURATION" -ge "$pk_right_dur_min" 2>/dev/null
        set out $out (set_color $pk_c_dur)(__pk_dur $CMD_DURATION)(set_color normal)
    end
    if test "$pk_right_clock" = 1
        set out $out (set_color $pk_c_time)(date "+$pk_clock_fmt")(set_color normal)
    end
    printf '%s' (string join ' ' $out)
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
abbr -a e nvim
abbr -a vim nvim
abbr -a vi nvim

alias ls   'eza --icons --group-directories-first --sort modified'
alias ll   'eza --icons --group-directories-first --sort modified -l --git'
alias la   'eza --icons --group-directories-first --sort modified -la --git'
alias lt   'eza --icons --group-directories-first --sort modified --tree --level=2'
alias tree 'eza --icons --tree'

#alias cat  'bat --paging=never'
#alias less 'bat'
#alias du   'dust'
#alias ps   'procs'
#alias top  'btm'
#alias sed  'sd'                          # UWAGA: inna skladnia niz sed
#alias find 'fd'                          # UWAGA: inna skladnia niz find
#alias grep 'rg'
#alias curl 'xh'                          # oryginal: 'command curl'
alias kubectl 'kubecolor'
#source /opt/homebrew/etc/grc.fish        # grc dla ping/df/traceroute/...

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
