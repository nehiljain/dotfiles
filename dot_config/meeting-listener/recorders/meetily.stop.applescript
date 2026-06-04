-- Triggers meetily "Stop Recording" via the menu-bar tray icon.
-- Defensive against (a) the tray sitting in menu bar 1 vs 2 depending on
-- whether a main window is open, and (b) the emoji prefix on menu items
-- during recording ("⏹ Stop Recording" rather than "Stop Recording").
-- Substring-matches the menu item and reports a real error if not found.
on run
    tell application id "com.meetily.ai" to activate
    delay 0.5
    tell application "System Events"
        tell process "meetily"
            -- Find the meetily tray icon. It can be in menu bar 1 or 2.
            set tray to missing value
            try
                set tray to menu bar item 1 of menu bar 2
            end try
            if tray is missing value then
                try
                    set tray to menu bar item 1 of menu bar 1
                end try
            end if
            if tray is missing value then
                error "meetily tray icon not found in any menu bar" number -1700
            end if

            -- Click to open menu; small retry loop because the menu sometimes
            -- doesn't materialize on the first click after a focus change.
            set menuOpen to false
            repeat 3 times
                click tray
                delay 0.4
                try
                    set items to name of every menu item of menu 1 of tray
                    if (count of items) > 0 then
                        set menuOpen to true
                        exit repeat
                    end if
                end try
                delay 0.2
            end repeat
            if not menuOpen then
                error "tray menu did not open" number -1701
            end if

            try
                set target to first menu item of menu 1 of tray whose name contains "Stop Recording"
                click target
            on error errMsg number errNum
                key code 53 -- escape; close menu
                error "Stop Recording menu item not found (" & errNum & "): " & errMsg
            end try
        end tell
    end tell
end run
