-- !!BassieOS_INFO!! { type = 11, name = "Files", version = 2, icon = "BIMG0403 11 11 11 00Ff1If1Lf1Ef1 11 11 11 11", author = "Bastiaan van der Plaat <bastiaan.v.d.plaat@gmail.com>" }
if BASSIEOS_VERSION == nil then
    print("This program needs BassieOS to run")
    return
end

local menu
local paths
local path
local files_list

local function LoadFolder(window_id)
    path = ""
    for i = 1, #paths do
        path = path .. paths[i]
    end
    SetWindowTitle(window_id, "Files - " .. path)

    menu = { "Up" }
    for i = 1, #paths do
        menu[#menu + 1] = paths[i]
    end

    local files = fs.list(path)
    files_list = {}
    for i = 1, #files do
        if fs.isDir(path .. files[i]) then
            files_list[#files_list + 1] = files[i] .. "/"
            files_list[#files_list + 1] = #fs.list(path .. files[i])

        end
    end
    for i = 1, #files do
        if not fs.isDir(path .. files[i]) then
            files_list[#files_list + 1] = files[i]
            files_list[#files_list + 1] = fs.getSize(path .. files[i])
        end
    end
end

local function FilesEventFunction(window_id, event, param1, param2, param3)
    if event == WINDOW_EVENT_CREATE then
        paths = { "/" }
        if args ~= nil and args[1] ~= nil and type(args[1]) == "string" and fs.exists(args[1]) and fs.isDir(args[1]) then
            for part in string.gmatch(args[1], "([^/]+)") do
                paths[#paths + 1] = part .. "/"
            end
        end
        LoadFolder(window_id)
    end
    if event == WINDOW_EVENT_MENU then
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
    if event == WINDOW_EVENT_MOUSE_UP then
        local x = param2
        local y = param3

        CheckWindowMenuClick(window_id, menu, x, y)

        for i = 1, #files_list, 2 do
            if x >= 0 and x < GetWindowWidth(window_id) and y == math.ceil(i / 2) then
                if string.sub(files_list[i], string.len(files_list[i])) == "/" then
                    paths[#paths + 1] = files_list[i]
                    LoadFolder(window_id)
                else
                    local info = GetProgramInfo(path .. files_list[i])
                    if info ~= nil and CheckOnion(info.type, BASSIEOS_INFO_TYPE_APP) then
                        RunProgram(path .. files_list[i])
                    else
                        RunProgram("/mini/edit.lua", { path .. files_list[i] })
                    end
                end
                return
            end
        end
    end
    if event == WINDOW_EVENT_PAINT then
        DrawWindowMenu(window_id, menu)
        for i = 1, math.min(#files_list, (GetWindowHeight(window_id) - 1) * 2), 2 do
            if string.sub(files_list[i], string.len(files_list[i])) == "/" then
                SetBackgroundColor(colors.yellow)
                DrawWindowText(window_id, CutString(files_list[i] .. " - " ..  files_list[i + 1] .. " files", GetWindowWidth(window_id)), 0, math.ceil(i / 2))
            else
                SetBackgroundColor(colors.white)
                DrawWindowText(window_id, files_list[i] .. " - " ..  math.ceil(files_list[i + 1] / 1024) .. " KB", 0, math.ceil(i / 2))
            end
        end
    end
end

CreateWindow("Files", WINDOW_USE_DEFAULT, WINDOW_USE_DEFAULT, 30, 14, FilesEventFunction)