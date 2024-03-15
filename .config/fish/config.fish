fenv source ~/.profile
atuin init fish | source
starship init fish | source
zoxide init fish | source

fish_vi_key_bindings

alias e=nvim
alias g=git
alias vim=nvim
alias ls='eza --icons'
alias bat=batcat

if status is-interactive
    # Commands to run in interactive sessions can go here
end


