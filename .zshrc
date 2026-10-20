# ============================================================================
#  .zshrc — czysty zsh bez frameworka. Pluginy z brew, `source` z /opt/homebrew.
#  Zasada jak w config.fish: zero forkow przy starcie i w promptcie.
#  Pomiar:  hyperfine -N -w 3 'zsh -i -c exit'
# ============================================================================

# p10k instant prompt: musi byc na samej gorze, przed czymkolwiek, co pisze na ekran
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

BREW=/opt/homebrew

# ============================================================================
#  PATH  (typeset -U = bez duplikatow; (N/) = tylko istniejace katalogi)
# ============================================================================
typeset -U path fpath
path=(
  # globalne wersje z mise bez `mise activate` (kazde wywolanie mise to ~200 ms);
  # link `global` mise aktualizuje po `mise use -g` / `mise install`.
  # Przed brew, bo brew tez ma node/terraform/kubectl/just.
  ~/.local/share/mise/installs/*/global/bin(N-/)
  ~/.local/share/mise/installs/*/global(N-/)    # `-` = podazaj za symlinkiem
  $BREW/bin $BREW/sbin
  ~/.local/bin ~/.cargo/bin ~/.docker/bin
  /Applications/WezTerm.app/Contents/MacOS(N/)
  $path
)
fpath=($BREW/share/zsh/site-functions $fpath)

# ============================================================================
#  ZACHOWANIE POWLOKI
# ============================================================================
export EDITOR=nvim VISUAL=nvim PAGER=less LESS='-R -F -X'
export MANPAGER='nvim +Man!'
export VIRTUAL_ENV_DISABLE_PROMPT=1
export AWS_PAGER=''
export BAT_THEME=srcery

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY       # czas wykonania w historii, jak `when:` w fishu
setopt HIST_VERIFY            # !! !$ !* najpierw rozwijaja sie w linii, Enter dopiero odpala
setopt AUTO_CD INTERACTIVE_COMMENTS NO_BEEP EXTENDED_GLOB

# compinit z cache: pelny skan najwyzej raz na dobe, poza tym -C (bez sprawdzania)
autoload -Uz compinit
# touch: compinit nie przepisuje niezmienionego dumpa, bez tego pelny skan szedlby przy kazdym starcie
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; touch ~/.zcompdump; else compinit -C; fi
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # bez rozrozniania wielkosci liter
zstyle ':completion:*' menu select
# menu pod Tab jak pager fisha: kolory plikow, grupy z naglowkami, opisy opcji
zstyle ':completion:*:default' list-colors ''   # '' = domyslne kolory zsh (katalogi, linki, exec)
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{11}-- %d --%f'
zstyle ':completion:*:messages' format '%F{13}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{9}-- brak dopasowan: %d --%f'
zstyle ':completion:*' use-cache on   # wolne completion (brew, pip) z cache w ~/.zcompcache

# ============================================================================
#  PROMPT  (szablon lean z brew + nadpisania w ~/.p10k.zsh)
# ============================================================================
# laptop, nie serwer: bez tego p10k sprawdza SSH przez `who am i` (fork, ~11 ms)
[[ -z $SSH_CONNECTION ]] && typeset -gx P9K_SSH=0 _P9K_SSH_TTY=$TTY
source $BREW/share/powerlevel10k/powerlevel10k.zsh-theme
source ~/.p10k.zsh

# Tlo transient promptu jak w config.fish: wykonana komenda dostaje niebieskie
# tlo na cala szerokosc = wyrazny separator w scrollbacku. p10k zostawia juz
# '❯ komenda'; preexec wraca kursorem na te linie i rysuje je ponownie z tlem.
# Ponownie rysowana komenda traci kolory skladni.
PK_TRANSIENT_BG='#1A4873'   # przygaszony srcery blue
_pk_transient_bg() {
  local -i last_status=$? rows=0 width
  local line
  for line in "${(@f)1}"; do
    width=${(m)#line}
    (( rows )) || width+=2               # '❯ ' tylko w pierwszej linii
    rows+=$(( width / COLUMNS + 1 ))
  done
  local char_color=10
  (( last_status )) && char_color=9
  print -Pn "%{\e[${rows}A\r%}%K{$PK_TRANSIENT_BG}%B%F{$char_color}❯%f%b "
  print -rn -- "${1//$'\n'/$'\e[K\n'}"
  print -Pn '\e[K%k\n'
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _pk_transient_bg

# ============================================================================
#  VI MODE  (zsh-vi-mode: text objects, surround, `.`, liczniki, vv -> nvim)
# ============================================================================
ZVM_LINE_INIT_MODE=i          # kazda nowa linia w insert, jak w fishu
ZVM_VI_SURROUND_BINDKEY=classic   # ys / cs / ds

# zsh-vi-mode nadpisuje bindy przy inicjalizacji, wiec cudze bindy dopiero tu
zvm_after_init() {
  source $BREW/opt/fzf/shell/key-bindings.zsh   # Ctrl-R, Ctrl-T, Alt-C
  bindkey -M viins '^F' autosuggest-accept      # jak ctrl-f w config.fish
  bindkey -M viins '^[e' zvm_vi_edit_command_line   # Alt-e jak w fishu
  bindkey -M vicmd '^[e' zvm_vi_edit_command_line
  # strzalka / k j: historia z wpisanym fragmentem, jak w fishu
  bindkey -M viins '^[[A' history-substring-search-up
  bindkey -M viins '^[[B' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
}
source $BREW/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $BREW/opt/fzf/shell/completion.zsh   # ** + Tab

# ============================================================================
#  INTEGRACJE  (kazda to JEDEN fork przy starcie)
# ============================================================================
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"   # z / zi

# ----------------------------------------------------------------------------
#  WLACZANE RECZNIE, tylko w biezacym oknie:
#    mise-on     wersje z mise.toml projektu (globalne sa zawsze w PATH, patrz gora)
#    direnv-on   .envrc przy kazdym cd
#  Oba hooki odpalaja proces przed KAZDYM promptem: mise ~200 ms, direnv ~18 ms
#  (zsh-bench: command_lag 26 ms -> 7 ms bez direnv).
# ----------------------------------------------------------------------------
alias mise-on='eval "$(mise activate zsh)"'
alias direnv-on='eval "$(direnv hook zsh)"'

# ============================================================================
#  ALIASY
# ============================================================================
(( $+commands[rgrc] )) && eval "$(rgrc --aliases)"

alias ls='eza --icons --group-directories-first --sort modified'
alias ll='eza --icons --group-directories-first --sort modified -l --git'
alias la='eza --icons --group-directories-first --sort modified -la --git'
alias lt='eza --icons --group-directories-first --sort modified --tree --level=2'
alias tree='eza --icons --tree'
alias kubectl=kubecolor
alias l=ls e=nvim vim=nvim vi=nvim

alias g=git gfa='git fetch --all' gs='git status' gd='git diff' ga='git add'
alias gc='git commit' gp='git push' gl='git pull --rebase' lg=lazygit

alias k=kubectl kgp='kubectl get pods' kgs='kubectl get svc' kd='kubectl describe' kl='kubectl logs -f'
alias kgn='kubectl get nodes -L eks.amazonaws.com/nodegroup,node.kubernetes.io/instance-type,topology.kubernetes.io/zone'

alias tf=terraform tfi='terraform init' tfp='terraform plan' tfa='terraform apply'
alias awsp='aws --profile' awsw='aws sts get-caller-identity'

cht() { xh -b "cht.sh/$1" User-Agent:curl }
mkcd() { mkdir -p "$1" && cd "$1" }
mkvi() { mkdir -p "${1:h}" && nvim "$1" }
upn() { local up_path=''; repeat $1 up_path+='../'; print "cd $up_path" }   # upn 3 -> cd ../../../

# lokalny tfstate w cloudboostr-ai-ecosystem/dev.justfile
alias tsp='just state-pull' tsm='just state-mv' tsls='just state-list'
alias tsl='just state-local' tsr='just state-remote'

# ============================================================================
#  PLUGINY NA KONCU  (kolejnosc z README: syntax-highlighting, potem substring-search)
# ============================================================================
# plugin bierze kolory z 5x $(tput ...) = 5 forkow (~40 ms); echoti to to samo wbudowane w zsh
tput() { echoti "$@" }
source $BREW/share/zsh-you-should-use/you-should-use.plugin.zsh   # "masz alias gs"
unfunction tput
add-zsh-hook -d preexec _check_git_aliases   # bez aliasow z .gitconfig: forkuje git+sort (~20 ms) przed kazdym `git ...`

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'   # brblack, jak fish_color_autosuggestion
ZSH_AUTOSUGGEST_MANUAL_REBIND=1          # bez przepinania widgetow przy kazdym prompcie
ZSH_AUTOSUGGEST_STRATEGY=(history completion)   # gdy historia nic nie ma, podpowiedz z completion (jak fish)
ZSH_AUTOSUGGEST_USE_ASYNC=1              # completion liczone w tle, pisanie nie czeka
source $BREW/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $BREW/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $BREW/share/zsh-history-substring-search/zsh-history-substring-search.zsh
