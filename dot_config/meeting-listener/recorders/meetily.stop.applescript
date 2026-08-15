-- Triggers meetily "Stop Recording" via the menu-bar tray icon.
-- Uses the accessibility action AXShowMenu to open the menu (works even
-- when meetily is in the background — plain `click` only opens the menu
-- when the process is foregrounded). Substring-matches the menu item
-- since recording-state labels have an emoji prefix like "⏹ Stop Recording".
--
-- Semantics: if the "Stop Recording" item doesn't exist, treat as success
-- (meetily isn't recording). Only real failures (tray missing, click error)
-- exit non-zero.
on run
    tell application id "com.meetily.ai" to activate
    delay 0.4
    tell application "System Events"
        tell process "meetily"
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
                error "meetily tray icon not found" number -1700
            end if

            try
                perform action "AXShowMenu" of tray
            on error
                click tray
            end try
            delay 0.4

            -- Enumerate the menu items defensively. If we can't even read the
            -- menu, that's a real failure.
            set itemNames to {}
            try
                set itemNames to name of every menu item of menu 1 of tray
            on error errMsg number errNum
                key code 53
                error "could not read tray menu (" & errNum & "): " & errMsg
            end try

            -- Look for the Stop Recording item (with emoji prefix).
            set stopIdx to 0
            repeat with i from 1 to count of itemNames
                set itemName to item i of itemNames
                if itemName is not missing value then
                    if itemName contains "Stop Recording" then
                        set stopIdx to i
                        exit repeat
                    end if
                end if
            end repeat

            if stopIdx = 0 then
                -- No Stop Recording item → meetily isn't recording. No-op.
                key code 53
                return "already-stopped"
            end if

            try
                click menu item stopIdx of menu 1 of tray
            on error errMsg number errNum
                key code 53
                error "click failed (" & errNum & "): " & errMsg
            end try
            return "stopped"
        end tell
    end tell
end run
