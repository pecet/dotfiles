export PATH="$HOME/.cargo/bin:$PATH"
export TERM="tmux-256color"
export COLORTERM="truecolor"

export LANG="en_US.UTF-8"
export LC_ALL=$LANG

eval "$(/opt/homebrew/bin/brew shellenv)"

# Commands to run in interactive sessions can go here
if status is-interactive
    export FZF_DEFAULT_OPTS="--tmux top,85%"
    zoxide init fish --hook prompt | source
    fzf_configure_bindings --directory=\ce
    #tide
end
mise activate fish | source
op completion fish | source

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/homebrew/anaconda3/bin/conda
    eval /opt/homebrew/anaconda3/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<

wezterm shell-completion --shell fish | source

# Created by `pipx` on 2025-01-01 20:10:33
set PATH $PATH /Users/pecet/.local/bin
export PATH="~/.local/bin/:$PATH"
