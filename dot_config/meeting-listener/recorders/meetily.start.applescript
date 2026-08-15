-- Triggers meetily "Start Recording" via the menu-bar tray icon.
-- Requires: Accessibility permission for the LaunchAgent's osascript.
-- Verified against meetily src-tauri/src/tray.rs (Start Recording item label).
on run
    tell application id "com.meetily.ai" to activate
    delay 0.6
    tell application "System Events"
        tell process "meetily"
            try
                set tray to menu bar item 1 of menu bar 2
            on error
                set tray to menu bar item 1 of menu bar 1
            end try
            click tray
            delay 0.3
            try
                click menu item "Start Recording" of menu 1 of tray
            on error errMsg
                key code 53 -- escape
                error "start_recording menu item not found: " & errMsg
            end try
        end tell
    end tell
end run
