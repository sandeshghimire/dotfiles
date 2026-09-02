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
alias gs='git status'    # not `gs` — that would shadow ghostscript
alias gd='git diff'
alias gc='git checkout'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate'

# Listing shortcuts (Omarchy's `ls` is already eza -lh --icons; `lsa`, `lt` exist)
alias ll='ls -lah'              # long, human sizes, incl. hidden files
alias lh='ls -lh'               # long, human sizes, visible files only
alias l='ls'                    # quick long listing
if command -v eza &>/dev/null; then
    alias la='eza -a --group-directories-first --icons=auto'    # short columns incl. hidden
fi

# Everyday helpers
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'
alias duh='du -h --max-depth=1 | sort -h'   # disk usage of cwd, sorted by size
alias ports='ss -tulpn'                      # listening sockets
alias hist='history'
