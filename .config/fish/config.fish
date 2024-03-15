fenv source ~/.profile
atuin init fish | source
starship init fish | source
zoxide init fish | source

fish_vi_key_bindings

alias vim=nvim
alias ls=exa
alias bat=batcat

if status is-interactive
    # Commands to run in interactive sessions can go here
end


