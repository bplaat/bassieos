-- BassieOS - A simple Operating System for the MineCraft ComputerCraft advanced color computer
-- Made by Bastiaan van der Plaat (https://github.com/bplaat)

-- ####################################### GLOBAL VARS ######################################

-- Global varirable that tells to do the event loop
do_event_loop = true

-- Global variable that holds the window objects
windows = {}

-- Global variable that holds the latest window_id
windows_id = 1

-- Global variable that holds the window_ids of the windows draw order
windows_order = {}

-- Global variable that holds the window_id of the focused window
windows_focus = nil

-- Global variable that holds the window_id of the window thats beeing draged
drag_window_id = nil

-- Global variable that holds the x position in the window of the window thats beeing draged
drag_x = 0

-- ####################################### PUBLIC API #######################################

-- The global constants
_G.BASSIEOS_VERSION = 1
_G.BASSIEOS_INFO_MAGIC = "-- !!BassieOS_INFO!! "

-- The global event constants
_G.EVENT_CREATE = 1
_G.EVENT_CLOSE = 2
_G.EVENT_PAINT = 3
_G.EVENT_FOCUS = 4
_G.EVENT_LOST_FOCUS = 5
_G.EVENT_MOVE = 6
_G.EVENT_RESIZE = 7
_G.EVENT_KEY = 8
_G.EVENT_MOUSE_DOWN = 9
_G.EVENT_MOUSE_UP = 10
_G.EVENT_MOUSE_DRAG = 11
_G.EVENT_MENU = 12

-- The global window style constants (must be power of two)
_G.WINDOW_STYLE_VISIBLE = 1
_G.WINDOW_STYLE_DECORATED = 2
_G.WINDOW_STYLE_FOCUSABLE = 4
_G.WINDOW_STYLE_RESIZABLE = 8
_G.WINDOW_STYLE_LISTED = 16
_G.WINDOW_STYLE_TOPMOST = 32

-- Function that checks of a bit by position in number on or off is
function _G.CheckBit(number, position)
   return bit.band(number, math.pow(2, position)) ~= 0
end

-- Function that splits a string to a table
function _G.SplitString(str, seperator)
    local result = {}
    for each in (str .. seperator):gmatch("(.-)" .. seperator) do
        result[#result + 1] = each
    end
    return result
end

-- Function that cuts a string and adds dots to the end
function _G.StringCut(text, width)
    if string.len(text) > width then
        return string.sub(text, 0, width - 2) .. ".."
    end
    return text .. string.rep(" ", width - string.len(text))
end

-- Function that opens a file and runs it as a function
function _G.RunProgram(path, args)
    if fs.exists(path) then
        local file = fs.open(path, "r")
        local program = load((args ~= nil and "local args = textutils.unserialize([[" .. textutils.serialize(args) .. "]])\n" or "") .. file.readAll(), path)
        file.close()
        if program ~= nil then
            program()
        end
    end
end

-- Function that parses the first line of a program which contains program info
function _G.GetProgramInfo(path)
    if fs.exists(path) then
        local file = fs.open(path, "r")
        local line = file.readLine()
        file.close()
        if string.sub(line, 0, string.len(BASSIEOS_INFO_MAGIC)) == BASSIEOS_INFO_MAGIC then
            return textutils.unserialize(string.sub(line, string.len(BASSIEOS_INFO_MAGIC)))
        end
    end
end

-- Get the terminal size
local screen_width, screen_height = term.getSize()

-- Function that returns the screen width
function _G.ScreenWidth()
    return screen_width
end

-- Function that returns the screen height
function _G.ScreenHeight()
    return screen_height
end

-- Function that returns the windows by window_id
function _G.GetWindows()
    local windows_ids = {}
    for i = 1, #windows do
        if windows[i] ~= 0 then
            windows_ids[#windows_ids + 1] = i
        end
    end
    return windows_ids
end

-- Function that returns the windows order by window_id
function _G.GetWindowsOrder()
    return windows_order
end

-- Function that returns the focused window
function _G.GetFocusedWindow()
    return windows_focus
end

-- Function the creates a new window and returns the new window_id
function _G.CreateWindow(title, x, y, width, height, event_function, style)
    -- Creates a window object, fills it with function params and adds it to the windows array
    local window = {}
    window.id = windows_id
    windows_id = windows_id + 1
    window.title = title
    window.x = x
    window.y = y
    window.width = width
    window.height = height
    window.event_function = event_function
    window.style = style or WINDOW_STYLE_LISTED + WINDOW_STYLE_RESIZABLE + WINDOW_STYLE_FOCUSABLE + WINDOW_STYLE_DECORATED + WINDOW_STYLE_VISIBLE
    window.minimized = false
    window.maximized = false
    windows[window.id] = window

    -- Send a EVENT_CREATE event to the new window
    SendWindowEvent(window.id, EVENT_CREATE)

    -- Add window to window order and focus the window
    windows_order[#windows_order + 1] = window.id
    FocusWindow(window.id)

    return window.id
end

-- Function that returns the window title by a window_id
function _G.GetWindowTitle(window_id)
    return windows[window_id].title
end

-- Function that sets the window title by a window_id
function _G.SetWindowTitle(window_id, title)
    windows[window_id].title = title
end

-- Function that returns the window x by a window_id
function _G.GetWindowX(window_id)
    return windows[window_id].maximized and 0 or windows[window_id].x
end

-- Function that sets the window x by a window_id
function _G.SetWindowX(window_id, x)
    if windows[window_id].x ~= x then
        windows[window_id].x = x
        SendWindowEvent(window_id, EVENT_MOVE)
    end
end

-- Function that returns the window y by a window_id
function _G.GetWindowY(window_id)
    return windows[window_id].maximized and 1 or windows[window_id].y
end

-- Function that sets the window y by a window_id
function _G.SetWindowY(window_id, y)
    if windows[window_id].y ~= y then
        windows[window_id].y = y
        SendWindowEvent(window_id, EVENT_MOVE)
    end
end

-- Function that returns the window width by a window_id
function _G.GetWindowWidth(window_id)
    return windows[window_id].maximized and ScreenWidth() or windows[window_id].width
end

-- Function that sets the window width by a window_id
function _G.SetWindowWidth(window_id, width)
    if windows[window_id].width ~= width then
        windows[window_id].width = width
        SendWindowEvent(window_id, EVENT_RESIZE)
    end
end

-- Function that returns the window height by a window_id
function _G.GetWindowHeight(window_id)
    return windows[window_id].maximized and ScreenHeight() - 2 or windows[window_id].height
end

-- Function that sets the window height by a window_id
function _G.SetWindowHeight(window_id, height)
    if windows[window_id].height ~= height then
        windows[window_id].height = height
        SendWindowEvent(window_id, EVENT_RESIZE)
    end
end

-- Function that returns the window style by a window_id
function _G.GetWindowStyle(window_id)
    return windows[window_id].style
end

-- Function that sets the window style by a window_id and refocus the window
function _G.SetWindowStyle(window_id, style)
    windows[window_id].style = style
    FocusWindow(window_id)
end

-- Function that returns if the window is minimized
function _G.IsWindowMinimized(window_id)
    return windows[window_id].minimized
end

-- Function that returns if the window is maximized
function _G.IsWindowMaximized(window_id)
    return windows[window_id].maximized
end

-- Function that sends an event to a window
function _G.SendWindowEvent(window_id, event, param1, param2, param3)
    windows[window_id].event_function(window_id, event, param1, param2, param3)
end

-- Function that checks of windows_focus is still the right window and sends some events
function _G.CheckWindowsFocus()
    -- Save the old focused window
    local old_windows_focus = windows_focus

    -- Loop trough the windows_order and make the first window without the style WINDOW_STYLE_NO_FOCUS and not minimized the focused window
    local new_windows_focus = nil
    for i = 1, #windows_order do
        if CheckBit(GetWindowStyle(windows_order[i]), 2) and not IsWindowMinimized(windows_order[i]) then
            new_windows_focus = windows_order[i]
            break
        end
    end
    windows_focus = new_windows_focus

    -- Check if the focused window isn"t the same one as the old one
    if old_windows_focus ~= windows_focus then
        -- If the old focused window isn"t closed the send a EVENT_LOST_FOCUS event
        if old_windows_focus ~= nil and windows[old_windows_focus] ~= 0 then
            SendWindowEvent(old_windows_focus, EVENT_LOST_FOCUS)
        end

        -- And send a EVENT_FOCUS event to the new focused window when not nil
        if windows_focus ~= nil then
            SendWindowEvent(windows_focus, EVENT_FOCUS)
        end
    end
end

-- Function that set the windows_focus to a window and changes the windows_order
function _G.FocusWindow(window_id)
    -- First check if a window has WINDOW_STYLE_TOPMOST
    if CheckBit(GetWindowStyle(window_id), 5) then
        -- Create a new windows order array
        local new_windows_order = {}

        -- Add the window_id
        new_windows_order[#new_windows_order + 1] = window_id

        -- Loop trough the windows order and add when it has window style WINDOW_STYLE_TOPMOST
        for i = 1, #windows_order do
            if CheckBit(GetWindowStyle(windows_order[i]), 5) and windows_order[i] ~= window_id then
                new_windows_order[#new_windows_order + 1] = windows_order[i]
            end
        end

        -- Loop trough the windows order and add when it has no window style WINDOW_STYLE_TOPMOST
        for i = 1, #windows_order do
            if not CheckBit(GetWindowStyle(windows_order[i]), 5) then
                new_windows_order[#new_windows_order + 1] = windows_order[i]
            end
        end

        -- Set the windows order to the new windows order array
        windows_order = new_windows_order
    else
        -- Create a new windows order array
        local new_windows_order = {}

        -- Loop trough the windows order and add when it has window style WINDOW_STYLE_TOPMOST
        for i = 1, #windows_order do
            if CheckBit(GetWindowStyle(windows_order[i]), 5) then
                new_windows_order[#new_windows_order + 1] = windows_order[i]
            end
        end

        -- Add the window_id
        new_windows_order[#new_windows_order + 1] = window_id

        -- Loop trough the windows order and add when it has no window style WINDOW_STYLE_TOPMOST
        for i = 1, #windows_order do
            if not CheckBit(GetWindowStyle(windows_order[i]), 5) and windows_order[i] ~= window_id then
                new_windows_order[#new_windows_order + 1] = windows_order[i]
            end
        end

        -- Set the windows order to the new windows order array
        windows_order = new_windows_order
    end

    -- Check the windows_focus global variable
    CheckWindowsFocus()
end

-- Function that minimize a window by window_id
function _G.MinimizeWindow(window_id)
    -- Set the minimized param on the window to true
    windows[window_id].minimized = true

    -- Copy the windows_order array to a new one
    local new_windows_order = {}
    for i = 1, #windows_order do
        if windows_order[i] ~= window_id then
            new_windows_order[#new_windows_order + 1] = windows_order[i]
        end
    end
    -- Insert itself at the end and set the windows_order array
    new_windows_order[#new_windows_order + 1] = window_id
    windows_order = new_windows_order

    -- Check the windows_focus global variable
    CheckWindowsFocus()
end

-- Function that shows a window after minimize by window_id
function _G.ShowWindow(window_id)
    windows[window_id].minimized = false
    FocusWindow(window_id)
end

-- Function that maximize a window by window_id
function _G.MaximizeWindow(window_id)
    windows[window_id].maximized = true
    SendWindowEvent(window_id, EVENT_RESIZE)
    FocusWindow(window_id)
end

-- Function that normals a window after maximize by window_id
function _G.NormalWindow(window_id)
    windows[window_id].maximized = false
    SendWindowEvent(window_id, EVENT_RESIZE)
    FocusWindow(window_id)
end

-- Function that closes a window by window_id
function _G.CloseWindow(window_id)
    -- Send a EVENT_CLOSE event to the window
    SendWindowEvent(window_id, EVENT_CLOSE)

    -- Delete the window in the windows array
    windows[window_id] = 0

    -- Filter the window_id out the windows order
    local new_windows_order = {}
    for i = 1, #windows_order do
        if windows_order[i] ~= window_id then
            new_windows_order[#new_windows_order + 1] = windows_order[i]
        end
    end
    windows_order = new_windows_order

    -- Check the windows_focus global variable
    CheckWindowsFocus()
end

-- Function that draws some text at a null-based position
function _G.DrawText(text, x, y)
    term.setCursorPos(x + 1, y + 1)
    term.write(text)
end

-- Function to draw text in a window
function _G.DrawWindowText(window_id, text, x, y)
    DrawText(text, GetWindowX(window_id) + x, GetWindowY(window_id) + y)
end

-- Function to draw lines in a window
function _G.DrawWindowLines(window_id, data, x, y)
    data = SplitString(data, "\n")
    for i = 1, #data do
        DrawText(data[i], GetWindowX(window_id) + x, GetWindowY(window_id) + y + (i - 1))
    end
end

-- Function that checks a menu click
function _G.CheckWindowMenuClick(window_id, menu, x, y)
    local offset = 0
    for i = 1, #menu do
        if x >= offset and x < offset + string.len(menu[i]) and y == 0 then
            SendWindowEvent(window_id, EVENT_MENU, i)
            return
        end
        offset = offset + string.len(menu[i]) + 1
    end
end

-- Function that draws a menu
function _G.DrawWindowMenu(window_id, menu)
    term.setTextColor(colors.white)
    term.setBackgroundColor(window_id == GetFocusedWindow() and colors.gray or colors.lightGray)
    DrawWindowText(window_id, string.rep(" ", GetWindowWidth(window_id)), 0, 0)
    local offset = 0
    for i = 1, #menu do
        DrawWindowText(window_id, menu[i], offset, 0)
        offset = offset + string.len(menu[i]) + 1
    end
    term.setTextColor(colors.black)
    term.setBackgroundColor(colors.white)
end

-- Function that closes the system
function _G.Shutdown()
    -- Close all the windows
    while #windows_order ~= 0 do
        CloseWindow(windows_order[1])
    end

    -- Stop the event loop in a minute
    do_event_loop = false
end

-- ######################################### WINDOW MANAGER #########################################

-- Save the current text color and background color
local text_color = term.getTextColor()
local background_color = term.getBackgroundColor()

-- Start the BassieOS bar
RunProgram("bar.lua")

-- Send a timer event to start the paint loop
os.startTimer(1 / 20)

-- A infinitive loop the gets events
while do_event_loop do
    local event, param1, param2, param3 = os.pullEvent()

    -- Paint the screen event
    if event == "timer" then
        -- Clear the screen with a background color
        term.setBackgroundColor(colors.cyan)
        term.clear()

        -- Draw the windows reverse via the windows order
        for i = #windows_order, 1, -1 do
            local window_id = windows_order[i]
            -- Check if the window has window style WINDOW_STYLE_VISIBLE and is not minimized
            if CheckBit(GetWindowStyle(window_id), 0) and not IsWindowMinimized(window_id) then
                -- Check if the window has window style WINDOW_STYLE_DECORATED
                if CheckBit(GetWindowStyle(window_id), 1) then
                    -- Draw the window boxes
                    term.setBackgroundColor(window_id == windows_focus and colors.black or colors.gray)
                    for y = 0, GetWindowHeight(window_id) + 1 do
                        DrawText(string.rep(" ", GetWindowWidth(window_id) + 2), GetWindowX(window_id) - 1, GetWindowY(window_id) - 1 + y)
                    end
                    term.setBackgroundColor(colors.white)
                    for y = 0, GetWindowHeight(window_id) - 1 do
                        DrawText(string.rep(" ", GetWindowWidth(window_id)), GetWindowX(window_id), GetWindowY(window_id) + y)
                    end

                    -- Draw the window header decorations
                    term.setTextColor(colors.white)
                    term.setBackgroundColor(window_id == windows_focus and colors.black or colors.gray)
                    DrawText(StringCut(GetWindowTitle(window_id), GetWindowWidth(window_id) - (CheckBit(GetWindowStyle(window_id), 3) and 4 or 3)), GetWindowX(window_id), GetWindowY(window_id) - 1)

                    -- Check window is resizable
                    if CheckBit(GetWindowStyle(window_id), 3) then
                        term.setBackgroundColor(colors.orange)
                        DrawText("_", GetWindowX(window_id) + GetWindowWidth(window_id) - 3, GetWindowY(window_id) - 1)
                        term.setBackgroundColor(colors.green)
                        DrawText(IsWindowMaximized(window_id) and "o" or "O", GetWindowX(window_id) + GetWindowWidth(window_id) - 2, GetWindowY(window_id) - 1)
                    else
                        term.setBackgroundColor(colors.orange)
                        DrawText("_", GetWindowX(window_id) + GetWindowWidth(window_id) - 2, GetWindowY(window_id) - 1)
                    end

                    term.setBackgroundColor(colors.red)
                    DrawText("X", GetWindowX(window_id) + GetWindowWidth(window_id) - 1, GetWindowY(window_id) - 1)
                end

                -- Send a EVENT_PAINT event to the window
                term.setTextColor(colors.black)
                term.setBackgroundColor(colors.white)
                SendWindowEvent(window_id, EVENT_PAINT)
            end
        end

        -- Register a event for the next paint
        os.startTimer(1 / 20)
    end

    --- Mouse down event
    if event == "mouse_click" then
        local button = param1
        local x = param2 - 1
        local y = param3 - 1

        -- Loop trough windows in windows_order
        for i = 1, #windows_order do
            local window_id = windows_order[i]
            -- Check if the window has window style WINDOW_STYLE_VISIBLE and is not minimized
            if CheckBit(GetWindowStyle(window_id), 0) and not IsWindowMinimized(window_id) then
                -- Check if a window is decorated
                if CheckBit(GetWindowStyle(window_id), 1) then
                    -- Check is click is in the window area
                    if x >= GetWindowX(window_id) - 1 and y >= GetWindowY(window_id) - 1 and
                        x < GetWindowX(window_id) + GetWindowWidth(window_id) + 1 and y < GetWindowY(window_id) + GetWindowHeight(window_id) + 1 then

                        -- Give the window focus
                        FocusWindow(window_id)

                        -- Check if not maximized and if the title is clicked then activate drag mode
                        if not IsWindowMaximized(window_id) and x >= GetWindowX(window_id) and y == GetWindowY(window_id) - 1 and
                            x < GetWindowX(window_id) + GetWindowWidth(window_id) - (CheckBit(GetWindowStyle(window_id), 3) and 3 or 2) then
                            drag_window_id = window_id
                            drag_x = x - GetWindowX(window_id)
                        end

                        -- Send event when window body is clicked
                        if x >= GetWindowX(window_id) and y >= GetWindowY(window_id) and
                            x < GetWindowX(window_id) + GetWindowWidth(window_id) and y < GetWindowY(window_id) + GetWindowHeight(window_id) then
                            SendWindowEvent(window_id, EVENT_MOUSE_DOWN, button, x - GetWindowX(window_id), y - GetWindowY(window_id))
                        end

                        break
                    end
                else
                    -- Check is click is in the window area
                    if x >= GetWindowX(window_id) and y >= GetWindowY(window_id) and
                        x < GetWindowX(window_id) + GetWindowWidth(window_id) and y < GetWindowY(window_id) + GetWindowHeight(window_id) then

                        -- Give the window focus
                        FocusWindow(window_id)

                        -- Send event because window body is clicked
                        SendWindowEvent(window_id, EVENT_MOUSE_DOWN, button, x - GetWindowX(window_id), y - GetWindowY(window_id))
                        break
                    end
                end
            end
        end
    end

    --- Mouse up event
    if event == "mouse_up" then
        local button = param1
        local x = param2 - 1
        local y = param3 - 1

        -- When a window is beeing draged release it
        if drag_window_id ~= nil then
            drag_window_id = nil
        else
            -- Loop trough windows in windows_order
            for i = 1, #windows_order do
                local window_id = windows_order[i]
                -- Check if the window has window style WINDOW_STYLE_VISIBLE and is not minimized
                if CheckBit(GetWindowStyle(window_id), 0) and not IsWindowMinimized(window_id) then
                    -- Check if a window is decorated
                    if CheckBit(GetWindowStyle(window_id), 1) then
                        -- Check window is resizable
                        if CheckBit(GetWindowStyle(window_id), 3) then
                            -- Check if minimize button is clicked
                            if x == GetWindowX(window_id) + GetWindowWidth(window_id) - 3 and y == GetWindowY(window_id) - 1  then
                                MinimizeWindow(window_id)
                                break
                            end

                            -- Check if maximize button is clicked
                            if x == GetWindowX(window_id) + GetWindowWidth(window_id) - 2 and y == GetWindowY(window_id) - 1  then
                                if IsWindowMaximized(window_id) then
                                    NormalWindow(window_id)
                                else
                                    MaximizeWindow(window_id)
                                end
                                break
                            end
                        else
                            -- Check if minimize button is clicked
                            if x == GetWindowX(window_id) + GetWindowWidth(window_id) - 2 and y == GetWindowY(window_id) - 1  then
                                MinimizeWindow(window_id)
                                break
                            end
                        end

                        -- Check if close button is clicked
                        if x == GetWindowX(window_id) + GetWindowWidth(window_id) - 1 and y == GetWindowY(window_id) - 1  then
                            CloseWindow(window_id)
                            break
                        end
                    end
                    -- Send event when window body is clicked
                    if x >= GetWindowX(window_id) and y >= GetWindowY(window_id) and
                        x < GetWindowX(window_id) + GetWindowWidth(window_id) and y < GetWindowY(window_id) + GetWindowHeight(window_id) then
                        SendWindowEvent(window_id, EVENT_MOUSE_UP, button, x - GetWindowX(window_id), y - GetWindowY(window_id))
                        break
                    end
                end
            end
        end
    end

    --- Mouse drag event
    if event == "mouse_drag" then
        local button = param1
        local x = param2 - 1
        local y = param3 - 1

        -- When a window is beeing draged change it"s position
        if drag_window_id ~= nil then
            SetWindowX(drag_window_id, x - drag_x)
            SetWindowY(drag_window_id, y + 1)
        else
            -- Loop trough windows in windows_order
            for i = 1, #windows_order do
                local window_id = windows_order[i]
                -- Check if the window has window style WINDOW_STYLE_VISIBLE and is not minimized
                if CheckBit(GetWindowStyle(window_id), 0) and not IsWindowMinimized(window_id) then
                    -- Send event when window body is clicked
                    if x >= GetWindowX(window_id) and y >= GetWindowY(window_id) and
                        x < GetWindowX(window_id) + GetWindowWidth(window_id) and y < GetWindowY(window_id) + GetWindowHeight(window_id) then
                        SendWindowEvent(window_id, EVENT_MOUSE_DRAG, button, x - GetWindowX(window_id), y - GetWindowY(window_id))
                        break
                    end
                end
            end
        end
    end

    -- Send a key event to the focused window by a key press
    if event == "key" and windows_focus ~= nil then
        SendWindowEvent(windows_focus, EVENT_KEY, param1, param2)
    end
end

-- Reset the terminal and stop
term.setTextColor(text_color)
term.setBackgroundColor(background_color)
term.clear()
term.setCursorPos(1, 1)