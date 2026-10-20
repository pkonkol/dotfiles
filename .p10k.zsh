# ============================================================================
#  .p10k.zsh — szablon „lean” z brew + nadpisania ponizej.
#  Szablon (wszystkie opcje z opisami):
#    /opt/homebrew/share/powerlevel10k/config/p10k-lean.zsh
#  Kolory to numery z palety terminala 0-15, wiec motyw srcery z wezterma
#  przechodzi sam: 8 brblack, 9 brred, 10 brgreen, 11 bryellow, 13 brmagenta, 15 brwhite.
# ============================================================================

source /opt/homebrew/share/powerlevel10k/config/p10k-lean.zsh

() {
  emulate -L zsh

  # --- jedna linia: lewo = gdzie jestem, prawo = stan ostatniej komendy ---
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir vcs prompt_char)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status command_execution_time background_jobs
    direnv virtualenv anaconda nix_shell
    kubecontext terraform aws
    time
  )
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

  # --- po Enter zostaje sam znak zachety; tlo dorysowuje _pk_transient_bg w .zshrc ---
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

  # --- host zawsze (domyslnie p10k pokazuje go tylko po ssh / jako root) ---
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%m'
  unset POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=10

  # --- kolory jak w config.fish ---
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=15
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=7
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=8
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=15
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED}_FOREGROUND=13
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=11
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=10
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=9
  typeset -g POWERLEVEL9K_STATUS_ERROR{,_SIGNAL,_PIPE}_FOREGROUND=9
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0.3   # s, jak pk_right_dur_min
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=8
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=11
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=8
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
}

(( ! $+functions[p10k] )) || p10k reload
