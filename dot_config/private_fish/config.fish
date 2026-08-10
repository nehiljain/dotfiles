if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Homebrew + user binaries on PATH.
# `fish_add_path -g` is idempotent (auto-deduplicated) and keeps this file the
# single source of truth. The old `set -U fish_user_paths ... $fish_user_paths`
# prepended on every launch, growing the universal variable and constantly
# rewriting fish_variables.
for brew_prefix in /opt/homebrew /usr/local
    if test -x $brew_prefix/bin/brew
        fish_add_path -g $brew_prefix/bin $brew_prefix/sbin
        break
    end
end
fish_add_path -g ~/.local/bin

source ~/.config/fish/aliases.fish

set -gx LS_COLORS "di=38;5;27:fi=38;5;7:ln=38;5;51:pi=40;38;5;11:so=38;5;13:or=38;5;197:mi=38;5;161:ex=38;5;9:"
set -gx TERM xterm-256color
set -g fish_greeting "Welcome to Fish, the friendly shell!"
set -gx EDITOR nvim
set -gx LLM_USER_PATH "$HOME/.config/io.datasette.llm/"

# Tool initialisation — guarded with `type -q` so a machine without these tools
# still starts cleanly. (poetry's one-time `virtualenvs.in-project` setting was
# moved out of here; it does not belong in per-shell startup.)
if type -q pyenv
    pyenv init - fish | source
end
if type -q atuin
    atuin init fish | source
end
