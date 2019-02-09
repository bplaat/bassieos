-- !!BassieOS_INFO!! { type = 8, name = "Window Manager", version = 2, author = "Bastiaan van der Plaat <bastiaan.v.d.plaat@gmail.com>" }
if BASSIEOS_VERSION == nil then
    print("This program needs BassieOS to run")
    return
end

local text_color = GetTextColor()
local background_color = GetBackgroundColor()
local drag_window
local drag_x = 0

os.startTimer(1 / 20)

while IsRunning() do
    local event, param1, param2, param3 = os.pullEvent()

    if event == "timer" then
        SetBackgroundColor(colors.cyan)
        term.clear()

        local windows_order = GetWindowsOrder()
        for i = #windows_order, 1, -1 do
            local window_id = windows_order[i]
            if HasWindowStyle(window_id, WINDOW_STYLE_VISIBLE) and not IsWindowMinimized(window_id) then
                if HasWindowStyle(window_id, WINDOW_STYLE_DECORATED) then
                    SetBackgroundColor(window_id == GetFocusWindow() and colors.black or colors.gray)
                    for y = 0, GetWindowHeight(window_id) + 1 do
                        DrawText(string.rep(" ", GetWindowWidth(window_id) + 2), GetWindowX(window_id) - 1, GetWindowY(window_id) - 1 + y)
                    end
                    SetBackgroundColor(colors.white)
                    for y = 0, GetWindowHeight(window_id) - 1 do
                        DrawText(string.rep(" ", GetWindowWidth(window_id)), GetWindowX(window_id), GetWindowY(window_id) + y)
                    end

                    SetColor(colors.white, window_id == GetFocusWindow() and colors.black or colors.gray)
                    DrawText(CutString(GetWindowTitle(window_id), GetWindowWidth(window_id) - (HasWindowStyle(window_id, WINDOW_STYLE_RESIZABLE) and 3 or 2)), GetWindowX(window_id), GetWindowY(window_id) - 1)

                    SetBackgroundColor(colors.orange)
                    DrawText("_", GetWindowX(window_id) + GetWindowWidth(window_id) - (HasWindowStyle(window_id, WINDOW_STYLE_RESIZABLE) and 3 or 2), GetWindowY(window_id) - 1)

                    if HasWindowStyle(window_id, WINDOW_STYLE_RESIZABLE) then
                        SetBackgroundColor(colors.green)
                        DrawText(IsWindowMaximized(window_id) and "o" or "O", GetWindowX(window_id) + GetWindowWidth(window_id) - 2, GetWindowY(window_id) - 1)
                    end

                    SetBackgroundColor(colors.red)
                    DrawText("X", GetWindowX(window_id) + GetWindowWidth(window_id) - 1, GetWindowY(window_id) - 1)
                end

                SetColor(colors.black, colors.white)
                SendWindowEvent(window_id, WINDOW_EVENT_PAINT)
            end
        end
        os.startTimer(1 / 20)
    end

    if event == "mouse_click" then
        local button = param1
        local x = param2 - 1
        local y = param3 - 1
        local windows_order = GetWindowsOrder()
        for i = 1, #windows_order do
            local window_id = windows_order[i]
            if HasWindowStyle(window_id, WINDOW_STYLE_VISIBLE) and not IsWindowMinimized(window_id) then
                if HasWindowStyle(window_id, WINDOW_STYLE_DECORATED) then
                    if x >= GetWindowX(window_id) - 1 and y >= GetWindowY(window_id) - 1 and x < GetWindowX(window_id) + GetWindowWidth(window_id) + 1 and y < GetWindowY(window_id) + GetWindowHeight(window_id) + 1 then
                        FocusWindow(window_id)
                        if not IsWindowMaximized(window_id) and x >= GetWindowX(window_id) and y == GetWindowY(window_id) - 1 and
                            x < GetWindowX(window_id) + GetWindowWidth(window_id) - (HasWindowStyle(window_id, WINDOW_STYLE_RESIZABLE) and 3 or 2) then
                            drag_window = window_id
                            drag_x = x - GetWindowX(window_id)
                            break
                        end
                        if x >= GetWindowX(window_id) and y >= GetWindowY(window_id) and
                            x < GetWindowX(window_id) + GetWindowWidth(window_id) and y < GetWindowY(window_id) + GetWindowHeight(window_id) then
                            SendWindowEvent(window_id, WINDOW_EVENT_MOUSE_DOWN, button, x - GetWindowX(window_id), y - GetWindowY(window_id))
                        end
                        break
                    end
                else
                    if x >= GetWindowX(window_id) and y >= GetWindowY(window_id) and
                        x < GetWindowX(window_id) + GetWindowWidth(window_id) and y < GetWindowY(window_id) + GetWindowHeight(window_id) then
                        FocusWindow(window_id)
                        SendWindowEvent(window_id, WINDOW_EVENT_MOUSE_DOWN, button, x - GetWindowX(window_id), y - GetWindowY(window_id))
                        break
                    end
                end
            end
        end
    end

    if event == "mouse_up" then
        local button = param1
        local x = param2 - 1
        local y = param3 - 1
        if drag_window ~= nil then
            drag_window = nil
        else
            local windows_order = GetWindowsOrder()
            for i = 1, #windows_order do
                local window_id = windows_order[i]
                if HasWindowStyle(window_id, WINDOW_STYLE_VISIBLE) and not IsWindowMinimized(window_id) then
                    if HasWindowStyle(window_id, WINDOW_STYLE_DECORATED) then
                        if x == GetWindowX(window_id) + GetWindowWidth(window_id) - (HasWindowStyle(window_id, WINDOW_STYLE_RESIZABLE) and 3 or 2) and y == GetWindowY(window_id) - 1  then
                            MinimizeWindow(window_id, true)
                            break
                        end
                        if HasWindowStyle(window_id, WINDOW_STYLE_RESIZABLE) and x == GetWindowX(window_id) + GetWindowWidth(window_id) - 2 and y == GetWindowY(window_id) - 1  then
                            MaximizeWindow(window_id, not IsWindowMaximized(window_id))
                            break
                        end
                        if x == GetWindowX(window_id) + GetWindowWidth(window_id) - 1 and y == GetWindowY(window_id) - 1  then
                            CloseWindow(window_id)
                            break
                        end
                    end
                    if x >= GetWindowX(window_id) and y >= GetWindowY(window_id) and x < GetWindowX(window_id) + GetWindowWidth(window_id) and y < GetWindowY(window_id) + GetWindowHeight(window_id) then
                        SendWindowEvent(window_id, WINDOW_EVENT_MOUSE_UP, button, x - GetWindowX(window_id), y - GetWindowY(window_id))
                        break
                    end
                end
            end
        end
    end

    if event == "mouse_drag" then
        local button = param1
        local x = param2 - 1
        local y = param3 - 1
        if drag_window ~= nil then
            SetWindowX(drag_window, x - drag_x)
            SetWindowY(drag_window, y + 1)
        else
            local windows_order = GetWindowsOrder()
            for i = 1, #windows_order do
                local window_id = windows_order[i]
                if HasWindowStyle(window_id, WINDOW_STYLE_VISIBLE) and not IsWindowMinimized(window_id) then
                    if x >= GetWindowX(window_id) and y >= GetWindowY(window_id) and x < GetWindowX(window_id) + GetWindowWidth(window_id) and y < GetWindowY(window_id) + GetWindowHeight(window_id) then
                        SendWindowEvent(window_id, WINDOW_EVENT_MOUSE_DRAG, button, x - GetWindowX(window_id), y - GetWindowY(window_id))
                        break
                    end
                end
            end
        end
    end

    if event == "key" and GetFocusWindow() ~= nil then
        SendWindowEvent(GetFocusWindow(), WINDOW_EVENT_KEY_DOWN, param1, param2)
    end

    if event == "key_up" and GetFocusWindow() ~= nil then
        SendWindowEvent(GetFocusWindow(), WINDOW_EVENT_KEY_UP, param1)
    end
end

SetColor(text_color, background_color)
term.clear()
term.setCursorPos(1, 1)