-- !!BassieOS_INFO!! { type = "BassieOS_APP", name = "Editor", version = 1 }

local MENU = { "Exit" }
local data = {}

function EventFunction(window_id, event, param1, param2, param3)
    if event == EVENT_CREATE then
        if args ~= nil and args.path ~= nil and fs.exists(args.path) and not fs.isDir(args.path) then
            SetWindowTitle(window_id, "Editor - " .. args.path)
            local file = fs.open(args.path, "r")
            local line
            repeat
                line = file.readLine()
                data[#data + 1] = line
            until line == nil
            file.close()
        end
    end
    if event == EVENT_MOUSE_UP then
        CheckWindowMenuClick(window_id, MENU, param2, param3)
    end
    if event == EVENT_MENU then
        if param1 == 1 then
            CloseWindow(window_id)
        end
    end
    if event == EVENT_PAINT then
        DrawWindowMenu(window_id, MENU)
        for i = 1, math.min(#data, GetWindowHeight(window_id) - 1) do
            DrawWindowText(window_id, string.sub(data[i], 0, GetWindowWidth(window_id)), 0, i)
        end
    end
end

if BASSIEOS_VERSION ~= nil then
    CreateWindow("Editor", math.floor((ScreenWidth() - 40) / 2), math.floor((ScreenHeight() - 14 - 1) / 2), 40, 14, EventFunction)
else
    print("This program needs BassieOS to run")
end