-- Triggers meetily "Stop Recording" via the menu-bar tray icon.
-- Menu items have an emoji status prefix while recording (e.g. "⏹ Stop
-- Recording"), so we substring-match instead of looking for an exact label.
-- Returns non-zero (via 'error') if the menu item couldn't be found OR
-- clicked, so the listener knows the auto-stop failed.
on run
    tell application id "com.meetily.ai" to activate
    delay 0.4
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
                set target to first menu item of menu 1 of tray whose name contains "Stop Recording"
                click target
            on error errMsg number errNum
                key code 53 -- escape, close menu
                error "Stop Recording menu item not found (" & errNum & "): " & errMsg
            end try
        end tell
    end tell
end run
