-- BassieOS_Info { type = 11, name = 'About', description = 'Some information about BassieOS', versionNumber = 30, versionString = '3.0', icon = 'BIMG0403SfaYfaSfa aaIf1Nf1Ff1Of1WfeIfeNfe ee', author = 'Bastiaan van der Plaat' }
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

        -- Draw about text
        BassieOS.DrawTextWrapped(bitmap, 1, 1, width - 2, 'BassieOS is made by the one and only Bastiaan van der Plaat.\n' ..
            'For the source code go to github.com/bplaat/bassieos\n\nRunning BassieOS version: v' .. BassieOS.VERSION_STRING, text_color, background_color)
    end
end

BassieOS.CreateWindow('About BassieOS', BassieOS.WindowStyle.STANDARD, BassieOS.CENTER_WINDOW, BassieOS.CENTER_WINDOW, 30, 10, WindowMessageFunction)
