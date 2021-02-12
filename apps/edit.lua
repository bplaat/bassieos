-- BassieOS_Info { type = 11, name = 'Edit', description = 'The file editor for BassieOS', versionNumber = 30, versionString = '3.0', icon = 'BIMG0403-0f-0f-0f-0fE0fD0fI0fT0f-0f-0f-0f-0f', author = 'Bastiaan van der Plaat' }

if BassieOS == nil then
    print('This program needs BassieOS to run')
    return
end

local menu = { 'New', 'Open', 'Save', 'Exit' }

local WindowMessageFunction = function (window_id, message, param1, param2, param3, param4)
    -- Handle menu messages
    if BassieOS.HandleWindowMenuMessage(
        window_id, menu,
        message, param1, param2, param3, param4
    ) then
        return
    end

    -- Handle back button
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

        -- Draw menu
        BassieOS.DrawWindowMenu(window_id, menu)
    end

    if message == BassieOS.WindowMessage.MENU then
        local menu_item = param1

        -- New button
        if menu_item == 1 then
            -- TODO
        end

        -- Open button
        if menu_item == 2 then
            -- TODO
        end

        -- Save button
        if menu_item == 3 then
            -- TODO
        end

        -- Exit button
        if menu_item == 4 then
            BassieOS.CloseWindow(window_id)
        end
    end
end

BassieOS.CreateWindow('Edit', BassieOS.WindowStyle.STANDARD, BassieOS.CENTER_WINDOW,
    BassieOS.CENTER_WINDOW, 30, 12, WindowMessageFunction)
