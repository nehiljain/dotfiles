# meeting-listener

Granola-style "meeting detected, start recording?" prompts for any macOS recorder.
Event-driven (no polling), recorder-agnostic.

## How it works

`log stream` on `com.apple.coreaudio`'s `update_running_state` events fires the
instant any process opens the mic — same signal that drives Apple's orange dot.
The listener filters to meeting apps, pops an `alerter` notification with a
Start button, and on click invokes the adapter for the configured recorder.

## Swap recorders

Set `ACTIVE_RECORDER` in `config.sh`. Adapter must export two bash functions:

```sh
recorder_start_recording() { ... }
recorder_stop_recording()  { ... }
```

Drop a new adapter at `recorders/<name>.sh` and flip the config var.

## Update meetily without touching anything

All meetily knowledge is in `recorders/meetily.sh` + the two `.applescript`
files. If meetily ships a `meetily://` URL scheme, replace the function bodies
with `open meetily://record/start` and `open meetily://record/stop`.

## Install (chezmoi managed)

```sh
brew install jq
chezmoi apply
```

`chezmoi apply` runs `run_onchange_setup_meeting-listener.sh.tmpl` which:
- Downloads pinned `alerter` (v26.5) from upstream releases into `~/.local/bin/alerter` if missing
- Loads (or reloads) the `com.nehiljain.meeting-listener` LaunchAgent

Re-runs automatically when the plist content or pinned alerter version
changes. macOS will prompt once on first run for **Accessibility** (osascript)
and **Automation → System Events** — accept both.

Grant once in **System Settings → Privacy & Security**:
- Accessibility → osascript
- Automation → System Events
- (and Microphone + Screen Recording for the recorder itself)

## Logs / debugging

```sh
tail -f ~/Library/Logs/meeting-listener.log

# Live signal preview (what the listener sees):
log stream --style ndjson \
  --predicate 'subsystem == "com.apple.coreaudio" AND eventMessage CONTAINS "update_running_state"'

# Reload after editing:
launchctl kickstart -k gui/$UID/com.nehiljain.meeting-listener
```

## Per-host overrides

Create `~/.config/meeting-listener/config.local.sh` (gitignored) — it's sourced
last by `config.sh`.
