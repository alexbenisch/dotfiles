
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi


# ~~~~~~~~~~~~~~~ Keybindings ~~~~~~~~~~~~~~~~~~~~~~~~

bindkey '^A' beginning-of-line  # Ctrl + A springt zum Zeilenanfang
bindkey '^E' end-of-line        # Ctrl + E springt zum Zeilenende
bindkey '^K' kill-line          # Ctrl + K löscht von Cursor bis Zeilenende
bindkey '^U' backward-kill-line # Ctrl + U löscht die gesamte Zeile
bindkey '^R' fzf-history-widget


# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~

setopt extended_glob null_glob
# Mit setzt du eine flexiblere Dateisuche und vermeidest unerwartete Zeichenketten,
# wenn keine Dateien gefunden werden. Ideal für Skripte und effizientes Arbeiten in der Shell.

path=(
    $path                           # Keep existing PATH entries
    $HOME/bin
    $HOME/.local/bin
    $SCRIPTS
)

# Remove duplicate entries and non-existent directories
typeset -U path
path=($^path(N-/))

export PATH

# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~


HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_IGNORE_SPACE  # Don't save when prefixed with space
setopt HIST_IGNORE_DUPS   # Don't save duplicate lines
setopt SHARE_HISTORY      # Share history between sessions

# FZF für History-Suche aktivieren
if command -v fzf >/dev/null 2>&1; then
  bindkey '^R' fzf-history-widget
fi



# ~~~~~~~~~~~~~~~ Prompt ~~~~~~~~~~~~~~~~~~~~~~~~

PURE_GIT_PULL=0

fpath+=($HOME/.config/zsh/pure)
# .zshrc
autoload -U promptinit; promptinit
prompt pure


# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~


# Set to superior editing mode

set -o vi

export VISUAL=nvim
export EDITOR=nvim
export TERM="tmux-256color"

export BROWSER="google-chrome-stable"

# Directories

export REPOS="$HOME/Repos"
export GITUSER="alexbenisch"
export GHREPOS="$REPOS/github.com/$GITUSER"
export DOTFILES="$GHREPOS/dotfiles"
#export LAB="$GHREPOS/lab"
export SCRIPTS="$DOTFILES/scripts"
export NEXTCLOUD="$HOME/Nextcloud/"
#export ZETTELKASTEN="$HOME/Zettelkasten"
#export STOW_TARGET=~/.config/

# Example aliases
# alias zshconfig="mate ~/.zshrc"
alias conflicts="systemctl --type=service"
alias devpod="devpod-cli"



#export MPLBACKEND=qtagg
#export ANTHROPIC_API_KEY=$(pass show api_keys/anthropic_api_key)
#export OPENAI_API_KEY=$(pass show api_keys/openai_api_key)
export PATH="${PATH}:/home/alex/bin"
#export PATH=
#export KUBECONFIG=/home/alex/.kube/config
#export TF_VAR_ssh_key="$(cat ~/.ssh/id_ed25519.pub)"
if [[ -f ~/.config/secrets/api_keys.gpg ]]; then
    eval "$(gpg --quiet --decrypt ~/.config/secrets/api_keys.gpg)"
fi

# ~~~~~~~~~~~~~~~ Completion ~~~~~~~~~~~~~~~~~~~~~~~~

fpath+=~/.zfunc

zstyle ':completion:*' menu select

autoload -Uz compinit
compinit -u

# ~~~~~~~~~~~~~~~ Sourcing ~~~~~~~~~~~~~~~~~~~~~~~~


source <(fzf --zsh)

#eval "$(direnv hook zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# ~~~~~~~~~~~~~~~ Misc ~~~~~~~~~~~~~~~~~~~~~~~~



fpath+=~/.zfunc; autoload -Uz compinit; compinit









