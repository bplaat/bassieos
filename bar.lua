function EventFunction(window_id, event, param1, param2, param3)
    if event == EVENT_MOUSE_UP then
        local x = param2
        local y = param3

        if x >= 0 and x <= 4 and y == 0 then
            ShutDown()
            return
        end

        local windows = GetWindows()
        local offset = 1
        for i = 1, #windows do
            if windows[i] ~= 0 and CheckBit(GetWindowStyle(i), 4) then
                if x >= 6 * offset and x < 6 * offset + 5 and y == 0 then
                    if i == GetFocusedWindow() then
                        MinimizeWindow(i)
                    elseif IsWindowMinimized(i) then
                        ShowWindow(i)
                    else
                        FocusWindow(i)
                    end
                end
                offset = offset + 1
            end
        end

        if x == GetWindowWidth(window_id) - 1 and y == 0 then
            local windows_order = GetWindowsOrder()
            local minimize = false

            for i = 1, #windows_order do
                if CheckBit(GetWindowStyle(windows_order[i]), 4) and not IsWindowMinimized(windows_order[i]) then
                    minimize = true
                    break
                end
            end

            for i = 1, #windows_order do
                if CheckBit(GetWindowStyle(windows_order[i]), 4) then
                    if minimize then
                        MinimizeWindow(windows_order[i])
                    else
                        ShowWindow(windows_order[i])
                    end
                end
            end
        end
    end
    if event == EVENT_PAINT then
        term.setBackgroundColor(colors.black)
        DrawWindowText(window_id, string.rep(" ", GetWindowWidth(window_id)), 0, 0)

        term.setTextColor(colors.white)
        DrawWindowText(window_id, "Start", 0, 0)

        local windows = GetWindows()
        local offset = 1
        for i = 1, #windows do
            if windows[i] ~= 0 and CheckBit(GetWindowStyle(i), 4) then
                term.setBackgroundColor(i == GetFocusedWindow() and colors.gray or colors.black)
                DrawWindowText(window_id, string.sub(GetWindowTitle(i), 0, 5), 6 * offset, 0)
                offset = offset + 1
            end
        end

        local time_label = textutils.formatTime(os.time(), true)
        if string.len(time_label) == 4 then
            time_label = "0" .. time_label
        end
        term.setBackgroundColor(colors.black)
        DrawWindowText(window_id, time_label, GetWindowWidth(window_id) - string.len(time_label) - 1, 0)
        DrawWindowText(window_id, " ", GetWindowWidth(window_id) - 1, 0)
    end
end

if BASSIEOS_VERSION ~= nil then
    CreateWindow("Bar", 0, ScreenHeight() - 1, ScreenWidth(), 1, EventFunction, WINDOW_STYLE_TOPMOST + WINDOW_STYLE_VISIBLE)
else
    print("This program needs BassieOS to run")
end