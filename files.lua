-- !!BassieOS_INFO!! { type = "BassieOS_APP", name = "Files", version = 1 }

local menu
local paths = { "/" }
local files_list

local function LoadFolder(window_id)
    local path = table.concat(paths)
    SetWindowTitle(window_id, "Files - " .. path)

    menu = { "Up" }
    for i = 1, #paths do
        table.insert(menu, paths[i])
    end

    local files = fs.list(path)
    files_list = {}
    for i = 1, #files do
        if fs.isDir(path .. files[i]) then
            table.insert(files_list, files[i] .. "/")
            table.insert(files_list, #fs.list(path .. files[i]))
            
        end
    end
    for i = 1, #files do
        if not fs.isDir(path .. files[i]) then
            table.insert(files_list, files[i])
            table.insert(files_list, fs.getSize(path .. files[i]))
        end
    end
end

function EventFunction(window_id, event, param1, param2, param3)
    if event == EVENT_CREATE then
        LoadFolder(window_id)
    end
    if event == EVENT_MENU then
        local menu_item = param1

        if menu_item == 1 then
            if #paths > 1 then
                paths[#paths] = nil
                LoadFolder(window_id)
                return
            end
        end

        for i = 1, #paths do
            if menu_item == i + 1 then
                for j = menu_item, #paths do
                    paths[j] = nil
                end
                LoadFolder(window_id)
                return
            end
        end
    end
    if event == EVENT_MOUSE_UP then
        local x = param2
        local y = param3

        CheckWindowMenuClick(window_id, menu, x, y)

        for i = 1, #files_list, 2 do
            if x > 0 and x < GetWindowWidth(window_id) - 1 and y == math.ceil(i / 2) then
                if string.sub(files_list[i], string.len(files_list[i])) == "/" then
                    table.insert(paths, files_list[i])
                    LoadFolder(window_id)
                else
                    local info = GetProgramInfo(table.concat(paths) .. files_list[i])
                    if info ~= nil and info["type"] == "BassieOS_APP" then
                        RunProgram(table.concat(paths) .. files_list[i])
                    end
                end
                return
            end
        end
    end
    if event == EVENT_PAINT then
        DrawWindowMenu(window_id, menu)
        for i = 1, math.min(#files_list, (GetWindowHeight(window_id) - 1) * 2), 2 do
            if string.sub(files_list[i], string.len(files_list[i])) == "/" then
                DrawWindowText(window_id, files_list[i] .. " - " ..  files_list[i + 1] .. " files", 1, math.ceil(i / 2))
            else
                DrawWindowText(window_id, files_list[i] .. " - " ..  math.ceil(files_list[i + 1] / 1024) .. " KB", 1, math.ceil(i / 2))
            end
        end
    end
end

if BASSIEOS_VERSION ~= nil then
    CreateWindow("Files", math.floor((ScreenWidth() - 30) / 2), math.floor((ScreenHeight() - 14 - 1) / 2), 30, 14, EventFunction)
else
    print("This program needs BassieOS to run")
end