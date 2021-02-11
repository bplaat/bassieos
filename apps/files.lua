-- BassieOS_Info { type = 11, name = 'Files', description = 'The file manager for BassieOS', versionNumber = 30, versionString = '3.0', icon = 'BIMG0403 11 11 11 00Ff1If1Lf1Ef1 11 11 11 11', author = 'Bastiaan van der Plaat' }
if BassieOS == nil then
    print('This program needs BassieOS to run')
    return
end

local WINDOW_MESSAGE_MENU = 1234

local path = nil
local paths = { '/' }
local folders = nil
local files = nil

local LoadFolder = function (window_id)
    path = ''
    for i = 1, #paths do
        path = path .. paths[i]
    end
    BassieOS.SetWindowTitle(window_id, 'Files - ' .. path)

    local files_list = fs.list(path)

    -- List all folders in current folder
    folders = {}
    for i = 1, #files_list do
        local file = files_list[i]
        if fs.isDir(path .. file) then
            folders[#folders + 1] = {
                name = file .. '/',
                size = #fs.list(path .. file)
            }
        end
    end

    table.sort(folders, function (a, b)
        return string.lower(a.name) < string.lower(b.name)
    end)

    -- List all files in current folder
    files = {}
    for i = 1, #files_list do
        local file = files_list[i]
        if not fs.isDir(path .. file) then
            files[#files + 1] = {
                name = file,
                size = fs.getSize(path .. file)
            }
        end
    end

    table.sort(files, function (a, b)
        return string.lower(a.name) < string.lower(b.name)
    end)
end

local WindowMessageFunction = function (window_id, message, param1, param2, param3, param4)
    if message == BassieOS.WindowMessage.CREATE then
        LoadFolder(window_id)
    end

    if message == BassieOS.WindowMessage.BACK then
        -- Handle back / up button
        if #paths > 1 then
            local new_paths = {}
            for j = 1, #paths - 1 do
                new_paths[j] = paths[j]
            end
            paths = new_paths

            LoadFolder(window_id)
            BassieOS.InvalidWindow(window_id, true)
        else
            BassieOS.CloseWindow(window_id)
        end
    end

    if message == BassieOS.WindowMessage.DRAW then
        local bitmap = param1
        local width = param2
        local height = param3

        local background_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.white or colors.gray
        local text_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.black or colors.white

        -- Draw background color
        BassieOS.FillRect(bitmap, 0, 0, width, height, ' ', text_color, background_color)

        -- Draw menu
        BassieOS.FillRect(bitmap, 0, 0, width, 1, ' ', text_color, background_color)
        local local_x = 0
        for i = 1, #paths do
            local menu_item = paths[i]
            BassieOS.DrawText(bitmap, local_x, 0, menu_item, text_color, background_color)
            local_x = local_x + string.len(menu_item) + 1
        end

        -- Draw folders list
        local offset_y = 1
        for i = 1, #folders do
            local folder = folders[i]
            BassieOS.DrawText(bitmap, 0, offset_y, folder.name .. ' - ' .. folder.size .. ' files', text_color, background_color)
            offset_y = offset_y + 1
        end

        -- Draw files list
        for i = 1, #files do
            local file = files[i]
            BassieOS.DrawText(bitmap, 0, offset_y, file.name .. ' - ' ..  math.ceil(file.size / 1024) .. ' KiB', text_color, background_color)
            offset_y = offset_y + 1
        end
    end

    if message == BassieOS.WindowMessage.MOUSE_UP then
        local button = param1
        local x = param2
        local y = param3

        -- Handle menu
        local local_x = 0
        for i = 1, #paths do
            local menu_item = paths[i]
            if
                x >= local_x and
                x < local_x + string.len(menu_item) and
                y == 0
            then
                BassieOS.SendWindowMessage(window_id, WINDOW_MESSAGE_MENU, i)
                return
            end
            local_x = local_x + string.len(menu_item) + 1
        end

        -- Handle folders list
        local offset_y = 1
        for i = 1, #folders do
            local folder = folders[i]
            if y == offset_y then
                paths[#paths + 1] = folder.name
                LoadFolder(window_id)
                BassieOS.InvalidWindow(window_id, true)
                return
            end
            offset_y = offset_y + 1
        end

        -- Handle files list
        for i = 1, #files do
            local file = files[i]
            if y == offset_y then
                local info = BassieOS.GetProgramInfo(path .. file.name)
                if info ~= nil and BassieOS.CheckProperty(info.type, BassieOS.ProgramInfoType.APP) then
                    BassieOS.CreateProcess(path .. file.name)
                else
                    if BassieOS.IsBassieImageFile(path .. file.name) then
                        BassieOS.CreateProcess("/apps/paint.lua", { path .. file.name })
                    else
                        BassieOS.CreateProcess("/apps/edit.lua", { path .. file.name })
                    end
                end
                return
            end
            offset_y = offset_y + 1
        end
    end

    if message == WINDOW_MESSAGE_MENU then
        -- Handle paths menu
        local menu_item = param1

        for i = 1, #paths do
            if menu_item == i then
                local new_paths = {}
                for j = 1, menu_item do
                    new_paths[j] = paths[j]
                end
                paths = new_paths

                LoadFolder(window_id)
                BassieOS.InvalidWindow(window_id, true)
                return
            end
        end
    end
end

BassieOS.CreateWindow('Files', BassieOS.WindowStyle.STANDARD, BassieOS.CENTER_WINDOW,
    BassieOS.CENTER_WINDOW, 30, 12, WindowMessageFunction)
