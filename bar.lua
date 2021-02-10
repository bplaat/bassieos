-- BassieOS_Info { type = 9, name = 'Bar', description = 'The BassieOS system bar', versionNumber = 30, versionString = '3.0', author = 'Bastiaan van der Plaat' }
if BassieOS == nil then
    print('This program needs BassieOS to run')
    return
end

local WindowMessageFunction = function (window_id, message, param1, param2, param3, param4)
    if message == BassieOS.WindowMessage.DRAW then
        local bitmap = param1
        local width = param2
        local height = param3

        local background_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.white or colors.black
        local text_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.black or colors.white
        local highlight_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.lightGray or colors.gray

        -- Draw background color
        BassieOS.FillRect(bitmap, 0, 0, width, height, ' ', text_color, background_color)

        -- Draw start button
        BassieOS.DrawText(bitmap, 0, 0, 'Start', text_color, background_color)

        -- Draw window buttons
        local window_ids = BassieOS.GetWindowIds()
        local windows_listed = 0
        for i = 1, #window_ids do
            local window_id = window_ids[i]
            if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.LISTED) then
                windows_listed = windows_listed + 1
            end
        end
        local item_width = math.floor((BassieOS.GetWindowWidth(window_id) - 6 - 6) / windows_listed)
        if item_width < 3 then
            item_width = 3
        end

        local item_x = 6
        local focus_window_id = BassieOS.GetFocusWindowId()
        for i = 1, #window_ids do
            local window_id = window_ids[i]
            if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.LISTED) then
                local window_title = BassieOS.GetWindowTitle(window_id)
                BassieOS.DrawText(bitmap, item_x, 0, BassieOS.EllipseString(window_title, item_width, true), text_color, window_id == focus_window_id and highlight_color or background_color)
                item_x = item_x + item_width
            end
        end

        -- Draw time
        local time_string = textutils.formatTime(os.time(), true)
        if string.len(time_string) == 4 then
            time_string = '0' .. time_string
        end
        BassieOS.DrawText(bitmap, width - string.len(time_string), 0, time_string, text_color, background_color)

        BassieOS.InvalidWindow(window_id, true)
    end

    if message == BassieOS.WindowMessage.MOUSE_UP then
        local button = param1
        local x = param2
        local y = param3

        -- Check start buttons
        if x >= 0 and x < 5 then
            BassieOS.CreateProcess('/apps/start.lua')
            return
        end

        -- Check window buttons
        local window_ids = BassieOS.GetWindowIds()
        local windows_listed = 0
        for i = 1, #window_ids do
            local window_id = window_ids[i]
            if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.LISTED) then
                windows_listed = windows_listed + 1
            end
        end
        local item_width = math.floor((BassieOS.GetWindowWidth(window_id) - 6 - 6) / windows_listed)
        if item_width < 3 then
            item_width = 3
        end

        local item_x = 6
        local focus_window_id = BassieOS.GetFocusWindowId()
        for i = 1, #window_ids do
            local window_id = window_ids[i]
            if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.LISTED) then
                if x >= item_x and x < item_x + item_width then
                    if window_id == focus_window_id then
                        BassieOS.MinimizeWindow(window_id, true)
                    elseif BassieOS.IsWindowMinimized(window_id) then
                        BassieOS.MinimizeWindow(window_id, false)
                    elseif BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.FOCUSABLE) then
                        BassieOS.FocusWindow(window_id)
                    end
                    return
                end
                item_x = item_x + item_width
            end
        end

        -- Check time button
        if x >= BassieOS.GetWindowWidth(window_id) - 5 and x < BassieOS.GetWindowWidth(window_id) then
            BassieOS.StopRunning()
            return
        end
    end
end

local bar_height = 1
BassieOS.SetScreenOffsetBottom(bar_height)
BassieOS.CreateWindow('Bar', BassieOS.WindowStyle.VISIBLE + BassieOS.WindowStyle.TOPMOST, 0, BassieOS.GetScreenHeight() - bar_height, BassieOS.GetScreenWidth(), bar_height, WindowMessageFunction)
