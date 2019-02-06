-- !!BassieOS_INFO!! { type = 'BassieOS_PROGRAM', name = 'BassieOS Bar', version = 1 }

local menu
local menu_window_id
local menu_width
local SHUTDOWN = 'Shutdown'

local LIST_WIDTH = 10

function MenuEventFunction(window_id, event, param1, param2, param3)
    if event == EVENT_CREATE then
        menu = {}
        local files = fs.list('.')
        for i = 1, #files do
            if not fs.isDir(files[i]) then
                local info = GetProgramInfo(files[i])
                if info ~= nil and info.type == 'BassieOS_APP' then
                    menu[#menu + 1] = info.name
                    menu[#menu + 1] = files[i]
                end
            end
        end

        menu_width = 0
        for i = 1, #menu, 2 do
            if string.len(menu[i]) > menu_width then
                menu_width = string.len(menu[i])
            end
        end
        if string.len(SHUTDOWN) > menu_width then
            menu_width = string.len(SHUTDOWN)
        end
    end
    if event == EVENT_MOUSE_UP then
        local x = param2
        local y = param3

        if x >= menu_width or y < GetWindowHeight(window_id) - (#menu / 2) - 2 or y == ScreenHeight() - 1 then
            CloseWindow(menu_window_id)
            menu_window_id = nil
        else
            for i = 1, #menu, 2 do
                if y == GetWindowHeight(window_id) - (#menu / 2) - 2 + math.floor(i / 2) then
                    RunProgram(menu[i + 1])
                    CloseWindow(menu_window_id)
                    menu_window_id = nil
                    return
                end
            end
            if y == GetWindowHeight(window_id) - 2 then
                Shutdown()
                return
            end
        end
    end
    if event == EVENT_PAINT then
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.gray)
        for i = 1, #menu, 2 do
            DrawWindowText(window_id, menu[i] .. string.rep(' ', menu_width - string.len(menu[i])), 0, GetWindowHeight(window_id) - (#menu / 2) - 2 + math.floor(i / 2))
        end
        DrawWindowText(window_id, SHUTDOWN .. string.rep(' ', menu_width - string.len(SHUTDOWN)), 0, GetWindowHeight(window_id) - 2)
    end
end

function EventFunction(window_id, event, param1, param2, param3)
    if event == EVENT_MOUSE_UP then
        local x = param2
        local y = param3

        if x >= 0 and x <= 4 then
            menu_window_id = CreateWindow('Menu', 0, 0, ScreenWidth(), ScreenHeight(), MenuEventFunction, WINDOW_STYLE_TOPMOST + WINDOW_STYLE_VISIBLE)
            return
        end

        local windows = GetWindows()
        local offset = 6
        for i = 1, #windows do
            if CheckBit(GetWindowStyle(windows[i]), 4) then
                if x >= offset and x < offset + LIST_WIDTH then
                    if windows[i] == GetFocusedWindow() then
                        MinimizeWindow(windows[i])
                    elseif IsWindowMinimized(windows[i]) then
                        ShowWindow(windows[i])
                    else
                        FocusWindow(windows[i])
                    end
                    return
                end
                offset = offset + LIST_WIDTH + 1
            end
        end

        if x == GetWindowWidth(window_id) - 1 then
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

            return
        end
    end
    if event == EVENT_PAINT then
        term.setBackgroundColor(colors.black)
        DrawWindowText(window_id, string.rep(' ', GetWindowWidth(window_id)), 0, 0)

        term.setTextColor(colors.white)
        if menu_window_id ~= nil then
            term.setBackgroundColor(colors.gray)
        end
        DrawWindowText(window_id, 'Start', 0, 0)

        local windows = GetWindows()
        local offset = 6
        for i = 1, #windows do
            if CheckBit(GetWindowStyle(windows[i]), 4) then
                term.setBackgroundColor(windows[i] == GetFocusedWindow() and colors.gray or colors.black)
                DrawWindowText(window_id, StringCut(GetWindowTitle(windows[i]), LIST_WIDTH), offset, 0)
                offset = offset + LIST_WIDTH + 1
            end
        end

        local time_label = textutils.formatTime(os.time(), true)
        if string.len(time_label) == 4 then
            time_label = '0' .. time_label
        end
        term.setBackgroundColor(colors.black)
        DrawWindowText(window_id, time_label, GetWindowWidth(window_id) - string.len(time_label) - 1, 0)
        DrawWindowText(window_id, ' ', GetWindowWidth(window_id) - 1, 0)
    end
end

if BASSIEOS_VERSION ~= nil then
    CreateWindow('Bar', 0, ScreenHeight() - 1, ScreenWidth(), 1, EventFunction, WINDOW_STYLE_TOPMOST + WINDOW_STYLE_VISIBLE)
else
    print('This program needs BassieOS to run')
end