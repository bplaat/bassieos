-- BassieOS_Info { type = 11, name = 'Tasks', description = 'A simple Task Manager for BassieOS', versionNumber = 30, versionString = '3.0', author = 'Bastiaan van der Plaat' }
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
        local secondary_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.gray or colors.lightGray

        -- Draw background color
        BassieOS.FillRect(bitmap, 0, 0, width, height, ' ', text_color, background_color)

        -- Draw open windows
        BassieOS.DrawText(bitmap, 1, 1, 'Focus window: #' .. BassieOS.GetFocusWindowId(), text_color, background_color)

        local window_order = BassieOS.GetWindowOrder()
        for i = 1, #window_order do
            local window_id = window_order[i]
            local window_title = BassieOS.GetWindowTitle(window_id)
            BassieOS.DrawText(bitmap, 1, i + 2, '#' .. window_id .. ' - ' .. (window_title ~= nil and window_title or 'ERROR'),
                (BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.VISIBLE) and not BassieOS.IsWindowMinimized(window_id)) and text_color or secondary_color, background_color)
        end

        BassieOS.InvalidWindow(window_id, true)
    end
end

BassieOS.CreateWindow('Task Manager', BassieOS.WindowStyle.STANDARD, BassieOS.CENTER_WINDOW, BassieOS.CENTER_WINDOW, 25, 10, WindowMessageFunction)
