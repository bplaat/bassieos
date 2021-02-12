-- BassieOS_Info { type = 11, name = 'Chars', description = 'Shows all possible characters', versionNumber = 30, versionString = '3.0', author = 'Bastiaan van der Plaat' }

if BassieOS == nil then
    print('This program needs BassieOS to run')
    return
end

local WindowMessageFunction = function (window_id, message, param1, param2, param3, param4)
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

        -- Draw all possible chars
        local local_x = 1
        local local_y = 1
        for i = 0, 256 - 1 do
            BassieOS.DrawCharacter(bitmap, local_x, local_y, i, text_color, background_color)

            if local_x == width - 2 then
                local_x = 1
                local_y = local_y + 1
            else
                local_x = local_x + 1
            end
        end
    end
end

BassieOS.CreateWindow('Chars', BassieOS.WindowStyle.STANDARD, BassieOS.CENTER_WINDOW,
    BassieOS.CENTER_WINDOW, 30, 12, WindowMessageFunction)
