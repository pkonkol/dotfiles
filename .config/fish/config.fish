fenv source ~/.profile
fish_vi_key_bindings
if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias vim=nvim
alias ls=exa
alias bat=batcat

starship init fish | source
zoxide init fish | source
atuin init fish | source

