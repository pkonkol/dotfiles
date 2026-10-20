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
setopt HIST_VERIFY            # !! !$ !* najpierw rozwijaja sie w linii, Enter dopiero odpala
setopt AUTO_CD INTERACTIVE_COMMENTS NO_BEEP EXTENDED_GLOB

# compinit z cache: pelny skan najwyzej raz na dobe, poza tym -C (bez sprawdzania)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # bez rozrozniania wielkosci liter
zstyle ':completion:*' menu select

# ============================================================================
#  PROMPT  (szablon lean z brew + nadpisania w ~/.p10k.zsh)
# ============================================================================
source $BREW/share/powerlevel10k/powerlevel10k.zsh-theme
source ~/.p10k.zsh

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
}
source $BREW/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $BREW/opt/fzf/shell/completion.zsh   # ** + Tab

# ============================================================================
#  INTEGRACJE  (kazda to JEDEN fork przy starcie)
# ============================================================================
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"   # z / zi

# Recznie, tylko w tym oknie. Oba hooki odpalaja proces przed KAZDYM promptem:
# mise ~200 ms, direnv ~18 ms (zsh-bench: command_lag 26 ms -> 7 ms bez direnv).
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

# ============================================================================
#  PLUGINY NA KONCU  (syntax-highlighting musi byc ostatni)
# ============================================================================
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'   # brblack, jak fish_color_autosuggestion
ZSH_AUTOSUGGEST_MANUAL_REBIND=1          # bez przepinania widgetow przy kazdym prompcie
source $BREW/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $BREW/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
