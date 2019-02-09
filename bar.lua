-- !!BassieOS_INFO!! { type = 9, name = "BassieBar", version = 2, author = "Bastiaan van der Plaat <bastiaan.v.d.plaat@gmail.com>" }
if BASSIEOS_VERSION == nil then
    print("This program needs BassieOS to run")
    return
end

local function BarEventFunction(window_id, event, param1, param2, param3)
     if event == WINDOW_EVENT_MOUSE_UP then
        local button = param1
        local x = param2
        local y = param3

        if x >= 0 and x < 5 then
            RunProgram("/mini/start.lua")
            return
        end

        local windows = GetWindows()
        local listed = 0
        for i = 1, #windows do
            if HasWindowStyle(windows[i], WINDOW_STYLE_LISTED) then
                listed = listed + 1
            end
        end
        list_width = math.floor((GetWindowWidth(window_id) - 12) / listed)
        if list_width < 3 then list_width = 3 end

        local offset = 6
        for i = 1, #windows do
            if HasWindowStyle(windows[i], WINDOW_STYLE_LISTED) then
                if x >= offset and x < offset + list_width - 1 then
                    if windows[i] == GetFocusWindow() then
                        MinimizeWindow(windows[i], true)
                    elseif IsWindowMinimized(windows[i]) then
                        MinimizeWindow(windows[i], false)
                    else
                        FocusWindow(windows[i])
                    end
                    return
                end
                offset = offset + list_width
            end
        end
        
        if x >= GetWindowWidth(window_id) - 5 and x < GetWindowWidth(window_id) then
            Shutdown()
            return
        end
    end
    if event == WINDOW_EVENT_PAINT then
        SetColor(colors.white, colors.black)
        DrawWindowText(window_id, "Start" .. string.rep(" ", GetWindowWidth(window_id) - 5), 0, 0)

        local windows = GetWindows()
        local listed = 0
        for i = 1, #windows do
            if HasWindowStyle(windows[i], WINDOW_STYLE_LISTED) then
                listed = listed + 1
            end
        end
        list_width = math.floor((GetWindowWidth(window_id) - 12) / listed)
        if list_width < 3 then list_width = 3 end

        local offset = 6
        for i = 1, #windows do
            if HasWindowStyle(windows[i], WINDOW_STYLE_LISTED) then
                SetBackgroundColor(windows[i] == GetFocusWindow() and colors.gray or colors.black)
                DrawWindowText(window_id, CutString(GetWindowTitle(windows[i]), list_width - 1), offset, 0)
                offset = offset + list_width
            end
        end

        local time_label = textutils.formatTime(os.time(), true)
        if string.len(time_label) == 4 then
            time_label = "0" .. time_label
        end
        SetBackgroundColor(colors.black)
        DrawWindowText(window_id, time_label, GetWindowWidth(window_id) - 5, 0)
    end
end

local window_id = CreateWindow("BassieBar", 0, GetScreenHeight() - 1, GetScreenWidth(), 1, BarEventFunction)
SetWindowStyle(window_id, WINDOW_STYLE_TOPMOST + WINDOW_STYLE_VISIBLE)