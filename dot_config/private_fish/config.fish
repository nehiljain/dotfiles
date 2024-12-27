if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Dynamically find and add Homebrew's bin and sbin directories to the PATH
set brew_path (find /opt/homebrew /usr/local -name "brew" -type f -print -quit 2>/dev/null)
if test -n "$brew_path"
    set brew_bin_dir (dirname $brew_path)
    set -U fish_user_paths $brew_bin_dir $brew_bin_dir/sbin $fish_user_paths
else
    echo "Warning: Homebrew not found. Please ensure it is installed."
end

source ~/.config/fish/aliases.fish

set -x -g LS_COLORS "di=38;5;27:fi=38;5;7:ln=38;5;51:pi=40;38;5;11:so=38;5;13:or=38;5;197:mi=38;5;161:ex=38;5;9:"
set -x -g TERM "xterm-256color"

# Enable useful Fish shell features
set -g -x fish_greeting "Welcome to Fish, the friendly shell!"

set -x -g EDITOR "cursor -w"
set -g -x LLM_USER_PATH "/Users/nehiljain/.config/io.datasette.llm/"