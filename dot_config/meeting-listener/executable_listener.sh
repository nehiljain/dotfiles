#!/bin/bash
# Event-driven mic listener. Recorder-agnostic — drives whichever adapter
# config.sh selects via ACTIVE_RECORDER.
#
# Adapter contract (sourced from recorders/$ACTIVE_RECORDER.sh):
#   recorder_start_recording   # called when user confirms "Start"
#   recorder_stop_recording    # called when user confirms "Stop"
#
# Signal source: macOS `log stream` on com.apple.coreaudio's
# audiomxd "update_running_state" events — the same event that drives
# the orange mic-in-use dot. Includes process name + PID.

set -u

DIR="${HOME}/.config/meeting-listener"
. "${DIR}/config.sh"

ADAPTER="${DIR}/recorders/${ACTIVE_RECORDER}.sh"
if [ ! -f "${ADAPTER}" ]; then
  echo "meeting-listener: no adapter at ${ADAPTER}" >&2
  exit 1
fi
. "${ADAPTER}"

STATE_DIR="${HOME}/.local/state/meeting-listener"
mkdir -p "${STATE_DIR}" "$(dirname "${LOG_FILE}")"
COOLDOWN_FILE="${STATE_DIR}/last_start_notify"
# Tracks the process name that triggered the active recording. Its presence
# means "we are recording right now". On mic-off from that same process the
# listener auto-stops without prompting.
ACTIVE_FILE="${STATE_DIR}/active_proc"

log() { printf '%s %s\n' "$(date -u +%FT%TZ)" "$*" >> "${LOG_FILE}"; }

# Map raw process names to friendlier display names for the notification.
# Keeps the technical name in the log; only the UI uses the friendly form.
friendly_name() {
  case "$1" in
    zoom.us)                       echo "Zoom" ;;
    "Slack Helper"|"Slack Helper"*) echo "Slack huddle" ;;
    "Google Chrome Helper"*)       echo "Google Meet" ;;
    "Arc Helper"*)                 echo "a meeting in Arc" ;;
    "Brave Browser Helper"*)       echo "a meeting in Brave" ;;
    Safari*)                       echo "a meeting in Safari" ;;
    firefox*)                      echo "a meeting in Firefox" ;;
    "Microsoft Teams"*|MSTeams*)   echo "Microsoft Teams" ;;
    WebexHelper)                   echo "Webex" ;;
    FaceTime)                      echo "FaceTime" ;;
    *)                             echo "$1" ;;
  esac
}

# -- helpers -----------------------------------------------------------------

within_cooldown() {
  local now last=0
  now=$(date +%s)
  [ -f "${COOLDOWN_FILE}" ] && last=$(cat "${COOLDOWN_FILE}" 2>/dev/null || echo 0)
  (( now - last < START_COOLDOWN_S ))
}

mark_cooldown() { date +%s > "${COOLDOWN_FILE}"; }

# Each notification runs in a subshell so the modal wait never blocks the
# log-stream pipe (we'd miss the matching stop event).

# osascript-based modal dialog. Returns the button label, or "@TIMEOUT" if
# the user didn't click anything. Reliable inline buttons on every macOS.
# If the adapter set $RECORDER_ICON (POSIX path to a .icns or image file)
# and the file exists, the dialog uses it; otherwise falls back to the
# generic note icon.
_dialog_prompt() {
  local title="$1" subtitle="$2" msg="$3" primary="$4" secondary="$5" timeout="$6"

  local icon_clause="with icon note"
  if [ -n "${RECORDER_ICON:-}" ] && [ -f "${RECORDER_ICON}" ]; then
    icon_clause="with icon (POSIX file \"${RECORDER_ICON}\")"
  fi

  /usr/bin/osascript <<EOF 2>/dev/null
try
    set r to display dialog "${msg}" ¬
        with title "${title}: ${subtitle}" ¬
        buttons {"${secondary}", "${primary}"} ¬
        default button "${primary}" ¬
        cancel button "${secondary}" ¬
        giving up after ${timeout} ¬
        ${icon_clause}
    if gave up of r then
        return "@TIMEOUT"
    else
        return button returned of r
    end if
on error errMsg number errNum
    if errNum is -128 then
        return "${secondary}"
    end if
    return "@ERROR"
end try
EOF
}

# Alerter-based notification. Honors $RECORDER_ICON (set by the adapter) for
# the app-icon spot on the left of the notification.
_alerter_prompt() {
  local title="$1" subtitle="$2" msg="$3" primary="$4" secondary="$5" timeout="$6"
  local extra=()
  if [ -n "${RECORDER_ICON:-}" ] && [ -f "${RECORDER_ICON}" ]; then
    extra+=(--app-icon "${RECORDER_ICON}")
  fi
  alerter \
    --title "${title}" \
    --subtitle "${subtitle}" \
    --message "${msg}" \
    --actions "${primary}" \
    --close-label "${secondary}" \
    --timeout "${timeout}" \
    --sound Glass \
    "${extra[@]}" 2>/dev/null
}

_prompt() {
  case "${NOTIFY_STYLE:-dialog}" in
    alerter) _alerter_prompt "$@" ;;
    *)       _dialog_prompt  "$@" ;;
  esac
}

notify_start() {
  local proc="$1" pid="$2"
  local friendly; friendly=$(friendly_name "$proc")
  (
    log "MIC-ON proc=${proc} pid=${pid} → prompt"
    local choice
    choice=$(_prompt \
      "Record this meeting?" \
      "${friendly}" \
      "Capture audio + transcript with ${ACTIVE_RECORDER}." \
      "Record" \
      "Not now" \
      "${NOTIFY_TIMEOUT_S}")
    case "$choice" in
      Record|"@ACTIONCLICKED")
        log "user: Record → start ${ACTIVE_RECORDER}"
        if recorder_start_recording >> "${LOG_FILE}" 2>&1; then
          printf '%s' "$proc" > "${ACTIVE_FILE}"
          log "active=${proc} (will auto-stop on its mic-off)"
        else
          log "recorder_start_recording FAILED — not marking active"
        fi
        ;;
      *) log "user: dismissed (${choice:-empty})" ;;
    esac
  ) &
}

# Auto-stop. No prompt — same app that triggered Record just released the
# mic, so the recording's bracket is closed cleanly.
auto_stop() {
  local proc="$1"
  (
    log "MIC-OFF proc=${proc} → auto-stop"
    if recorder_stop_recording >> "${LOG_FILE}" 2>&1; then
      rm -f "${ACTIVE_FILE}"
      log "auto-stop OK"
    else
      log "recorder_stop_recording FAILED — leaving active state"
    fi
  ) &
}

# -- main loop ---------------------------------------------------------------

log "starting (adapter=${ACTIVE_RECORDER} pid=$$)"

# audiomxd emits one JSON event per mic state change. We extract:
#   .session.name      → "<proc>(<pid>)"
#   .details.input_running     → true/false
#   .details.implicit_category → typically "Record" when starting
#
# `log stream` ndjson wraps it inside the outer line's eventMessage field.
exec /usr/bin/log stream --style ndjson \
  --predicate 'subsystem == "com.apple.coreaudio" AND eventMessage CONTAINS "update_running_state"' \
| while IFS= read -r line; do
    msg=$(printf '%s' "$line" | /usr/bin/jq -r '.eventMessage // empty' 2>/dev/null) || continue
    [ -z "$msg" ] && continue

    # The eventMessage embeds a JSON blob — grab the first { ... }
    blob=$(printf '%s' "$msg" | /usr/bin/grep -oE '\{.*\}' | head -1)
    [ -z "$blob" ] && continue

    name=$(printf '%s' "$blob" | /usr/bin/jq -r '.session.name // empty' 2>/dev/null)
    running=$(printf '%s' "$blob" | /usr/bin/jq -r '.details.input_running' 2>/dev/null)
    [ -z "$name" ] && continue

    proc="${name%(*}"
    pid="${name##*(}"; pid="${pid%)}"

    [[ "$proc" =~ $IGNORE_REGEX ]] && continue
    [[ ! "$proc" =~ $MEET_APP_REGEX ]] && continue

    if [ "$running" = "true" ]; then
      # Already recording? Skip the prompt — same or another meeting app
      # opened the mic while we're already capturing.
      [ -f "${ACTIVE_FILE}" ] && continue
      within_cooldown && continue
      mark_cooldown
      notify_start "$proc" "$pid"
    elif [ "$running" = "false" ]; then
      # Only auto-stop if THIS proc is the one we started recording for.
      # Other apps releasing the mic while we record are noise.
      if [ -f "${ACTIVE_FILE}" ] && [ "$(cat "${ACTIVE_FILE}" 2>/dev/null)" = "$proc" ]; then
        auto_stop "$proc"
      fi
    fi
  done
