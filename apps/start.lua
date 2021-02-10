-- BassieOS_Info { type = 11, name = 'Start', description = 'The BassieOS application starter', versionNumber = 30, versionString = '3.0', author = 'Bastiaan van der Plaat' }
if BassieOS == nil then
    print('This program needs BassieOS to run')
    return
end

local apps = {}
local standard_icon = BassieOS.LoadImage('BIMG0403 ff 0fX0e 0f ff 00 00 ff ff ff ff ff')

local WindowMessageFunction = function (window_id, message, param1, param2, param3, param4)
    if message == BassieOS.WindowMessage.CREATE then
        -- Index application files in all folders except rom and git folder
        local function CheckDirectory (dir)
            local files = fs.list(dir)
            for i = 1, #files do
                local file = dir .. files[i]
                if fs.isDir(file) and (file ~= '/rom' or file ~= '/.git') then
                    CheckDirectory(file .. '/')
                else
                    local info = BassieOS.GetProgramInfo(file)
                    if info ~= nil and BassieOS.CheckProperty(info.type, BassieOS.ProgramInfoType.APP) then
                        apps[#apps + 1] = {
                            icon = info.icon ~= nil and BassieOS.LoadImage(info.icon) or standard_icon,
                            name = info.name,
                            path = file
                        }
                    end
                end
            end
        end
        CheckDirectory('/')
    end

    if message == BassieOS.WindowMessage.BACK then
        BassieOS.CloseWindow(window_id)
    end

    if message == BassieOS.WindowMessage.DRAW then
        local bitmap = param1
        local width = param2
        local height = param3

        local background_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.white or colors.gray
        local text_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.black or colors.white

        -- Draw background color
        BassieOS.FillRect(bitmap, 0, 0, width, height, ' ', text_color, background_color)

        -- Draw icon grid
        local max_tiles = math.floor((BassieOS.GetWindowWidth(window_id) - 1) / 7)
        local offset_x = 1 + math.floor((BassieOS.GetWindowWidth(window_id) - max_tiles * 7) / 2)
        local offset_y = 1
        local column = 0
        local row = 0
        for i = 1, #apps do
            BassieOS.DrawBitmap(bitmap, column * 7 + 1 + offset_x, row * 5 + offset_y, apps[i].icon)

            BassieOS.DrawText(bitmap, column * 7 + offset_x, row * 5 + 3 + offset_y, BassieOS.EllipseString(apps[i].name, 6, true), text_color, background_color)

            if column == max_tiles - 1 then
                column = 0
                row = row + 1
            else
                column = column + 1
            end
        end
    end

    if message == BassieOS.WindowMessage.MOUSE_UP then
        local button = param1
        local x = param2
        local y = param3

        -- Handle icon grid
        local max_tiles = math.floor((BassieOS.GetWindowWidth(window_id) - 1) / 7)
        local offset_x = 1 + math.floor((BassieOS.GetWindowWidth(window_id) - max_tiles * 7) / 2)
        local offset_y = 1
        local column = 0
        local row = 0
        for i = 1, #apps do
            if x >= column * 7 + offset_x and y >= row * 5 + offset_y and x < column * 7 + 6 + offset_x and y < row * 5 + 4 + offset_y then
                BassieOS.CreateProcess(apps[i].path)
                BassieOS.CloseWindow(window_id)
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
end

BassieOS.CreateWindow('Start any program', BassieOS.WindowStyle.STANDARD, BassieOS.CENTER_WINDOW, BassieOS.CENTER_WINDOW, 30, 11, WindowMessageFunction)
