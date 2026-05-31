#!/bin/bash
# Lite setup for MacBook Air — travel machine.
# Run once on a fresh macOS install.
set -euo pipefail

DOTFILES_REPO="nehiljain/dotfiles"

# ── Helpers ───────────────────────────────────────────────────────────────────
step() { echo; echo "▶ $*"; }
ok()   { echo "  ✓ $*"; }

# ── 1. Homebrew ───────────────────────────────────────────────────────────────
step "Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
ok "brew $(brew --version | head -1)"

# ── 2. Chezmoi + dotfiles ────────────────────────────────────────────────────
step "Chezmoi → applying dotfiles (git, ssh, nvim, tmux)"
brew install chezmoi
# init clones the repo; apply --exclude scripts skips the run_onchange brew
# script (which installs the full Brewfile — we use Brewfile.lite instead)
chezmoi init "$DOTFILES_REPO"
chezmoi apply --exclude scripts
CHEZMOI_SRC="$(chezmoi source-path)"
ok "dotfiles applied from $CHEZMOI_SRC"

# ── 3. Patch fish config for lite machine ────────────────────────────────────
step "Patching fish config (removing pyenv/poetry/cursor, adding zoxide)"
FISH_CONFIG="$HOME/.config/fish/config.fish"

# Remove lines that reference tools not installed on this machine
sed -i '' \
  '/pyenv init/d;/poetry config/d;/LLM_USER_PATH/d' \
  "$FISH_CONFIG"

# Set editor to nvim instead of cursor
sed -i '' 's|EDITOR "cursor -w"|EDITOR "nvim"|g' "$FISH_CONFIG"

# Add zoxide init (replaces z plugin)
if ! grep -q 'zoxide init' "$FISH_CONFIG"; then
  echo 'zoxide init fish | source' >> "$FISH_CONFIG"
fi

# Tell chezmoi not to manage this file on this machine going forward
# (so a future `chezmoi apply` won't overwrite our patch)
chezmoi forget "$FISH_CONFIG" 2>/dev/null || true
ok "fish config patched + removed from chezmoi tracking"

# ── 4. Install packages ───────────────────────────────────────────────────────
step "Installing packages from Brewfile.lite"
brew bundle --file="$CHEZMOI_SRC/Brewfile.lite"
ok "all packages installed"

# ── 5. Fish as default shell ─────────────────────────────────────────────────
step "Setting Fish as default shell"
FISH_PATH="$(brew --prefix)/bin/fish"
grep -qF "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
if [ "$SHELL" != "$FISH_PATH" ]; then
  # dscl works on Apple ID accounts where chsh fails with auth errors
  if ! sudo dscl . -create "/Users/$USER" UserShell "$FISH_PATH" 2>/dev/null; then
    echo "  ⚠ dscl failed — run manually: chsh -s $FISH_PATH"
    echo "    or change via: System Settings → Users & Groups → right-click user → Advanced Options"
  fi
fi
ok "default shell → $FISH_PATH"

# ── 6. Fisher + fish plugins ─────────────────────────────────────────────────
step "Installing Fisher plugins"
"$FISH_PATH" -c '
  if not functions -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
  end
  fisher install PatrickF1/fzf.fish franciscolourenco/done IlanCosman/tide@v6
'
ok "fzf.fish, done, tide@v6"

# ── 7. Tide prompt config ─────────────────────────────────────────────────────
step "Configuring tide prompt"
"$FISH_PATH" -c "tide configure --auto \
  --style=Lean \
  --prompt_colors='True color' \
  --show_time='24-hour format' \
  --lean_prompt_height='Two lines' \
  --prompt_connection=Dotted \
  --prompt_connection_andor_frame_color=Dark \
  --prompt_spacing=Sparse \
  --icons='Few icons' \
  --transient=No"
ok "tide configured (Lean, Dotted, Two lines)"

# ── 8. Git: wire up delta ────────────────────────────────────────────────────
step "Configuring git delta"
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light false
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default
ok "delta configured as git pager + difftool"

# ── Done ─────────────────────────────────────────────────────────────────────
echo
echo "══════════════════════════════════════════════════"
echo "  Setup complete. Remaining manual steps:"
echo "══════════════════════════════════════════════════"
echo "  1. Open 1Password → Settings → Developer → enable SSH Agent"
echo "  2. Open Ghostty (fish launches automatically via config)"
echo "  3. tide configure  (choose your prompt style)"
echo "  4. atuin login --username nehiljain  (sync shell history)"
echo "  5. Open Obsidian → connect your vault (iCloud / git)"
echo "  6. Open Raycast → set launch shortcut, sign in"
echo "  7. Open Rectangle → grant accessibility permission"
echo "  8. Open Karabiner-Elements → grant Input Monitoring permission"
echo "══════════════════════════════════════════════════"
