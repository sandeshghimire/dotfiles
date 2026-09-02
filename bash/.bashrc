# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Start a fullscreen screen recording
alias oc='omarchy screenrecord --fullscreen'
# Stop the screen recording
alias ox='omarchy screenrecord --stop-recording'

. "$HOME/.cargo/env"

# Serial terminal helper (defines `serial` function)
[[ -r ~/tools/serial.sh ]] && source ~/tools/serial.sh

# Git shortcuts
alias gm='git commit'
alias ga='git add'
alias gp='git push'
alias gl='git pull'
alias gst='git status'    # not `gs` — that would shadow ghostscript
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glg='git log --oneline --graph --decorate'
