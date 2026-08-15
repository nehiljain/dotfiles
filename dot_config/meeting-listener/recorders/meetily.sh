# meetily adapter — ALL meetily-specific knowledge lives here.
#
# Why GUI scripting: as of 2026-06-02, meetily.app exposes no URL scheme,
# CLI, or local HTTP endpoint for recording control. Recording is reachable
# only through the in-app WebView's Tauri IPC, which the menu-bar tray
# triggers via a sessionStorage handoff.
#
# Migration path: if meetily ships a deep-link plugin
# (https://github.com/Zackriya-Solutions/meetily/issues — file a request),
# replace both function bodies with one-liners:
#     open "meetily://record/start"
#     open "meetily://record/stop"
# Nothing else in this repo changes.

_meetily_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

RECORDER_ICON="/Applications/meetily.app/Contents/Resources/app_icon.icns"

recorder_start_recording() {
  /usr/bin/osascript "${_meetily_dir}/meetily.start.applescript"
}

recorder_stop_recording() {
  /usr/bin/osascript "${_meetily_dir}/meetily.stop.applescript"
}
