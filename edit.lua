-- !!BassieOS_INFO!! { type = 11, name = "Editor", version = 2, icon = "BIMG0403i3ff3f ffx5f ff ffp2fr2fe3fn3fd3f ff", author = "Bastiaan van der Plaat <bastiaan.v.d.plaat@gmail.com>" }
if BASSIEOS_VERSION == nil then
    print("This program needs BassieOS to run")
    return
end

local menu = { "New", "Open", "Save", "Exit" }
local data = {}

local function EditEventFunction(window_id, event, param1, param2, param3)
    if event == WINDOW_EVENT_CREATE then
        if args ~= nil and args[1] ~= nil and type(args[1]) == "string" and fs.exists(args[1]) and not fs.isDir(args[1]) then
            SetWindowTitle(window_id, "Editor - " .. args[1])
            local file = fs.open(args[1], "r")
            local line
            repeat
                line = file.readLine()
                data[#data + 1] = line
            until line == nil
            file.close()
        end
    end
    if event == WINDOW_EVENT_MOUSE_UP then
        CheckWindowMenuClick(window_id, menu, param2, param3)
    end
    if event == WINDOW_EVENT_MENU then
        if param1 == 4 then
            CloseWindow(window_id)
        end
    end
    if event == WINDOW_EVENT_PAINT then
        DrawWindowMenu(window_id, menu)
        for i = 1, math.min(#data, GetWindowHeight(window_id) - 1) do
            DrawWindowText(window_id, string.sub(data[i], 0, GetWindowWidth(window_id)), 0, i)
        end
    end
end

CreateWindow("Editor", WINDOW_USE_DEFAULT, WINDOW_USE_DEFAULT, 40, 14, EditEventFunction)