-- !!BassieOS_INFO!! { type = 11, name = "Tasks", version = 2, author = "Bastiaan van der Plaat <bastiaan.v.d.plaat@gmail.com>" }
if BASSIEOS_VERSION == nil then
    print("This program needs BassieOS to run")
    return
end

local menu = { "Exit" }

local function TaskEventFunction(window_id, event, param1, param2, param3)
    if event == WINDOW_EVENT_MOUSE_UP then
        CheckWindowMenuClick(window_id, menu, param2, param3)
    end
    if event == WINDOW_EVENT_MENU then
        if param1 == 1 then
            CloseWindow(window_id)
        end
    end
    if event == WINDOW_EVENT_PAINT then
        DrawWindowMenu(window_id, menu)
        DrawWindowText(window_id, "Focused window: " .. (GetFocusWindow() ~= nil and ("#" .. GetFocusWindow()) or "none"), 1, 2)
        local windows_order = GetWindowsOrder()
        for i = 1, #windows_order do
            DrawWindowText(window_id, "#" .. windows_order[i] .. " - \"" .. CutString(GetWindowTitle(windows_order[i]), 12) .. "\" - " ..
                GetWindowX(windows_order[i]) .. "x" .. GetWindowY(windows_order[i]) .. " " .. 
                GetWindowWidth(windows_order[i]) .. "x" .. GetWindowHeight(windows_order[i]) .. " - " ..
                GetWindowStyle(windows_order[i]) .. (IsWindowMaximized(windows_order[i]) and " - max" or "") ..
                (IsWindowMinimized(windows_order[i]) and " - min" or ""), 1, i + 2)
        end
    end
end

CreateWindow("Task Manager", WINDOW_USE_DEFAULT, WINDOW_USE_DEFAULT, 45, 14, TaskEventFunction)