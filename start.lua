-- !!BassieOS_INFO!! { type = 9, name = "Start", version = 2, author = "Bastiaan van der Plaat <bastiaan.v.d.plaat@gmail.com>" }
if BASSIEOS_VERSION == nil then
    print("This program needs BassieOS to run")
    return
end

local apps = {}
local standard_icon = "BIMG0403 ff.0f.0fX0e ff 00 00 ff ff ff ff ff"

local function StartEventFunction(window_id, event, param1, param2, param3)
    if event == WINDOW_EVENT_CREATE then
        local files = fs.list("/mini/")
        for i = 1, #files do
            if not fs.isDir(files[i]) then
                local info = GetProgramInfo("/mini/" .. files[i])
                if info ~= nil and CheckOnion(info.type, BASSIEOS_INFO_TYPE_APP) then
                    apps[#apps + 1] = { icon = info.icon, name = info.name, path = "/mini/" .. files[i] }
                end
            end
        end
    end
    if event == WINDOW_EVENT_MOUSE_UP then
        local button = param1
        local x = param2
        local y = param3

        local max_tiles = math.floor(GetWindowWidth(window_id) / 7)
        local column = 0
        local row = 0
        for i = 1, #apps do
            if x >= column * 7 and y >= row * 5 and x < column * 7 + 6 and y < row * 5 + 4 then
                RunProgram(apps[i].path)
                CloseWindow(window_id)
                return
            end
            if column == max_tiles - 1 then
                column = 0
                row = row + 1
            else
                column = column + 1
            end
        end
    end
    if event == WINDOW_EVENT_PAINT then
        local max_tiles = math.floor(GetWindowWidth(window_id) / 7)
        local column = 0
        local row = 0
        for i = 1, #apps do
            DrawWindowImage(window_id, apps[i].icon or standard_icon, column * 7 + 1, row * 5, 4, 3)
            DrawWindowText(window_id, CutString(apps[i].name, 6), column * 7, row * 5 + 3)
            if column == max_tiles - 1 then
                column = 0
                row = row + 1
            else
                column = column + 1
            end
        end
    end
end

CreateWindow("Start any program", WINDOW_USE_DEFAULT, WINDOW_USE_DEFAULT, 30, 10, StartEventFunction)