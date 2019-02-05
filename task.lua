-- !!BassieOS_INFO!! { type = "BassieOS_APP", name = "Tasks", version = 1 }

function EventFunction(window_id, event, param1, param2, param3)
    if event == EVENT_PAINT then
        local focused_window = GetFocusedWindow()
        DrawWindowText(window_id, "Focused window: " .. (focused_window ~= nil and ("#" .. focused_window) or "none"), 1, 1)
        local windows_order = GetWindowsOrder()
        for i = 1, #windows_order do
            DrawWindowText(window_id, "#" .. windows_order[i] .. " - " .. GetWindowTitle(windows_order[i]) .. " - " ..
                GetWindowX(windows_order[i]) .. "x" .. GetWindowY(windows_order[i]) .. " " .. 
                GetWindowWidth(windows_order[i]) .. "x" .. GetWindowHeight(windows_order[i]) .. " - " ..
                GetWindowStyle(windows_order[i]) .. (IsWindowMaximized(windows_order[i]) and " - max" or "") ..
                (IsWindowMinimized(windows_order[i]) and " - min" or ""), 1, i + 1)
        end
    end
end

if BASSIEOS_VERSION ~= nil then
    CreateWindow("Task Manager", math.floor((ScreenWidth() - 45) / 2), math.floor((ScreenHeight() - 14 - 1) / 2), 45, 14, EventFunction)
else
    print("This program needs BassieOS to run")
end