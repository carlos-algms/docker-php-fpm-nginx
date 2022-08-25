PROMPT=$'\n'"%B%F{green}%n%f %F{blue}%~%f%b"$'\n'"λ "

alias ls='/bin/ls --color=auto -F --group-directories-first'
alias ll='ls -l'
alias l='ls -lA'

# Cycle through history based on characters already typed on the line
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
