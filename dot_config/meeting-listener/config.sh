# meeting-listener config — sourced by listener.sh
# Override per-machine via ~/.config/meeting-listener/config.local.sh (gitignored).

ACTIVE_RECORDER="meetily"

# Notification UI:
#   "dialog"  → osascript display dialog. Modal, reliable inline buttons,
#               brief focus-steal. Works on every macOS, no config needed.
#   "alerter" → notification-style via alerter binary. No focus-steal but on
#               macOS Sequoia the buttons collapse into an "Options" dropdown
#               unless the sender bundle is configured as Alerts style
#               (alerter doesn't register a unique sender so this isn't
#                practical for now).
NOTIFY_STYLE="alerter"

# Process names (from audiomxd "session.name") that count as a meeting.
# Match against the bare name (PID stripped). Edit freely.
MEET_APP_REGEX='^(zoom\.us|Google Chrome Helper.*|Arc Helper.*|Brave Browser Helper.*|firefox.*|Safari.*|Slack Helper.*|Microsoft Teams.*|MSTeams.*|WebexHelper|FaceTime)$'

# Names we always ignore (the recorder itself, voice-input tools, etc.)
IGNORE_REGEX='^(meetily|BetterDictation|Wispr Flow|MacWhisper|Granola|cleft)$'

NOTIFY_TIMEOUT_S=20         # alerter timeout for start prompt
STOP_NOTIFY_TIMEOUT_S=15    # alerter timeout for stop prompt
START_COOLDOWN_S=30         # suppress repeat start prompts within this window
LOG_FILE="${HOME}/Library/Logs/meeting-listener.log"

# Allow per-host overrides without polluting the repo
[ -f "${HOME}/.config/meeting-listener/config.local.sh" ] && \
  . "${HOME}/.config/meeting-listener/config.local.sh"
