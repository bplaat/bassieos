-- BassieOS_Info { type = 11, name = 'Paint', description = 'A simple drawing program', versionNumber = 30, versionString = '3.0', icon = 'BIMG0403=b3=b3=b3=b3Dafr1fa4fw5f=b3=b3=b3=b3', author = 'Bastiaan van der Plaat' }
if BassieOS == nil then
    print('This program needs BassieOS to run')
    return
end

local menu = { 'New', 'Open', 'Save', 'Exit' }

local canvas_path = '/image.bimg'
local canvas_bitmap = nil
local canvas_character = ' '
local canvas_text_color = colors.white
local canvas_background_color = colors.black

local canvas_resize = {}
canvas_resize.is_enabled = false
canvas_resize.is_east = false
canvas_resize.is_south = false

local WindowMessageFunction = function (window_id, message, param1, param2, param3, param4)
    if message == BassieOS.WindowMessage.CREATE then
        BassieOS.SetWindowMinWidth(window_id, 16 + 5)
        BassieOS.SetWindowMinHeight(window_id, 5)

        local width = BassieOS.GetWindowWidth(window_id)
        local height = BassieOS.GetWindowHeight(window_id)

        if
            args ~= nil and args[1] ~= nil and type(args[1]) == 'string' and
            fs.exists(args[1]) and not fs.isDir(args[1])
        then
            local file = fs.open(args[1], 'r')
            if file ~= nil then
                local contents = file.readAll()
                file.close()
                if contents ~= nil then
                    canvas_path = args[1]
                    BassieOS.SetWindowTitle(window_id, 'Paint - ' .. canvas_path)
                    canvas_bitmap = BassieOS.BassieImageToBitmap(contents)
                    return
                else
                    BassieOS.CreateMessage('Paint', 'Can\'t open file: ' .. canvas_path)
                end
            else
                BassieOS.CreateMessage('Paint', 'Can\'t open file: ' .. canvas_path)
            end
        end

        canvas_bitmap = BassieOS.CreateBitmap(width - 1, height - 4)
    end

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
        local text_background_color = colors.lightGray
        local tools_background_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.lightGray or colors.gray
        local text_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.black or colors.white

        -- Draw background color
        BassieOS.FillRect(bitmap, 0, 0, width, height, 127, text_background_color, background_color)

        -- Draw menu
        BassieOS.DrawWindowMenu(window_id, menu)

        -- Draw canvas bitmap
        BassieOS.DrawBitmap(bitmap, 0, 1, canvas_bitmap)

        -- Draw text color picker
        BassieOS.FillRect(bitmap, 0, height - 2, width, 1, 127, text_background_color, background_color)
        local color_width = math.floor((width - 5) / 16)

        local offset_x = math.floor((width - 5 - color_width * 16) / 2)
        BassieOS.DrawText(bitmap, offset_x, height - 2, 'Text:', text_color, tools_background_color)
        offset_x = offset_x + 5

        for i = 0, 15 do
            BassieOS.DrawText(bitmap, offset_x + i * color_width, height - 2, string.rep(2 ^ i == canvas_text_color and '#' or '.', color_width), 2 ^ i < colors.gray and colors.black or colors.white, 2 ^ i)
        end

        -- Draw background color picker
        BassieOS.FillRect(bitmap, 0, height - 1, width, 1, 127, text_background_color, background_color)

        offset_x = math.floor((width - 5 - color_width * 16) / 2)
        BassieOS.DrawText(bitmap, offset_x, height - 1, 'Back:', text_color, tools_background_color)
        offset_x = offset_x + 5

        for i = 0, 15 do
            BassieOS.DrawText(bitmap, offset_x + i * color_width, height - 1, string.rep(2 ^ i == canvas_background_color and '#' or '.', color_width), 2 ^ i < colors.gray and colors.black or colors.white, 2 ^ i)
        end
    end

    if message == BassieOS.WindowMessage.KEY_CHAR then
        local character = param1
        canvas_character = character
    end

    if message == BassieOS.WindowMessage.MOUSE_DOWN then
        local button = param1
        local x = param2
        local y = param3

        -- Handle bitmap
        if
            x >= 0 and
            y >= 1 and
            x < canvas_bitmap.width and
            y <= canvas_bitmap.height
        then
            last_x = x
            last_y = y - 1
            BassieOS.DrawCharacter(canvas_bitmap, x, y - 1, canvas_character, canvas_text_color, canvas_background_color)
            BassieOS.InvalidWindow(window_id, true)
        end

        -- Handle bitmap east resizer
        if
            x == canvas_bitmap.width and
            y >= 1 and
            y <= canvas_bitmap.height + 1
        then
            canvas_resize.is_enabled = true
            canvas_resize.is_east = true
        end

        -- Handle bitmap south resizer
        if
            x >= 0 and
            x <= canvas_bitmap.width and
            y == canvas_bitmap.height + 1
        then
            canvas_resize.is_enabled = true
            canvas_resize.is_south = true
        end
    end

    if message == BassieOS.WindowMessage.MOUSE_DRAG then
        local button = param1
        local x = param2
        local y = param3

        if canvas_resize.is_enabled then
            -- Handle bitmap east resizer
            if canvas_resize.is_east then
                local new_width = x
                if new_width >= 1 then
                    local old_canvas_bitmap = canvas_bitmap
                    canvas_bitmap = BassieOS.CreateBitmap(new_width, canvas_bitmap.height)
                    last_x = nil
                    last_y = nil
                    BassieOS.DrawBitmap(canvas_bitmap, 0, 0, old_canvas_bitmap)
                    BassieOS.InvalidWindow(window_id, true)
                end
            end

            -- Handle bitmap south resizer
            if canvas_resize.is_south then
                local new_height = y - 1
                if new_height >= 1 then
                    local old_canvas_bitmap = canvas_bitmap
                    canvas_bitmap = BassieOS.CreateBitmap(canvas_bitmap.width, new_height)
                    last_x = nil
                    last_y = nil
                    BassieOS.DrawBitmap(canvas_bitmap, 0, 0, old_canvas_bitmap)
                    BassieOS.InvalidWindow(window_id, true)
                end
            end
        else
            -- Handle bitmap
            if
                x >= 0 and
                y >= 1 and
                x < canvas_bitmap.width and
                y <= canvas_bitmap.height
            then
                last_x = x
                last_y = y - 1
                BassieOS.DrawCharacter(canvas_bitmap, x, y - 1, canvas_character, canvas_text_color, canvas_background_color)
                BassieOS.InvalidWindow(window_id, true)
            end
        end
    end

    if message == BassieOS.WindowMessage.MOUSE_UP then
        local button = param1
        local x = param2
        local y = param3

        if canvas_resize.is_enabled then
            canvas_resize.is_enabled = false
            canvas_resize.is_east = false
            canvas_resize.is_south = false
        else
            local width = BassieOS.GetWindowWidth(window_id)
            local height = BassieOS.GetWindowHeight(window_id)

            -- Handle text color picker
            local color_width = math.floor((width - 5) / 16)
            local offset_x = math.floor((width - 5 - color_width * 16) / 2) + 5
            for i = 0, 15 do
                if
                    x >= offset_x + i * color_width and
                    x < offset_x + i * color_width + color_width and
                    y == height - 2
                then
                    canvas_text_color = 2 ^ i
                    if button == 2 then
                        canvas_background_color = 2 ^ i
                    end

                    BassieOS.InvalidWindow(window_id, true)
                    return
                end
            end

            -- Handle background color picker
            local color_width = math.floor((width - 5) / 16)
            local offset_x = math.floor((width - 5 - color_width * 16) / 2) + 5
            for i = 0, 15 do
                if
                    x >= offset_x + i * color_width and
                    x < offset_x + i * color_width + color_width and
                    y == height - 1
                then
                    if button == 2 then
                        canvas_text_color = 2 ^ i
                    end
                    canvas_background_color = 2 ^ i

                    BassieOS.InvalidWindow(window_id, true)
                    return
                end
            end
        end
    end

    if message == BassieOS.WindowMessage.MENU then
        local menu_item = param1

        -- New button
        if menu_item == 1 then
            BassieOS.SetWindowTitle(window_id, 'Paint')
            canvas_bitmap = BassieOS.CreateBitmap(canvas_bitmap.width, canvas_bitmap.height)
            last_x = nil
            last_y = nil
            BassieOS.InvalidWindow(window_id, true)
        end

        -- Open button
        if menu_item == 2 then
            local file = fs.open(canvas_path, 'r')
            if file ~= nil then
                local contents = file.readAll()
                file.close()
                if contents ~= nil then
                    BassieOS.SetWindowTitle(window_id, 'Paint - ' .. canvas_path)
                    canvas_bitmap = BassieOS.BassieImageToBitmap(contents)
                    last_x = nil
                    last_y = nil
                    BassieOS.InvalidWindow(window_id, true)
                else
                    BassieOS.CreateMessage('Paint', 'Can\'t open file: ' .. canvas_path)
                end
            else
                BassieOS.CreateMessage('Paint', 'Can\'t open file: ' .. canvas_path)
            end
        end

        -- Save button
        if menu_item == 3 then
            BassieOS.SetWindowTitle(window_id, 'Paint - ' .. canvas_path)
            local file = fs.open(canvas_path, 'w')
            file.write(BassieOS.BitmapToBassieImage(canvas_bitmap))
            file.close()
        end

        -- Exit button
        if menu_item == 4 then
            BassieOS.CloseWindow(window_id)
        end
    end
end

BassieOS.CreateWindow('Paint', BassieOS.WindowStyle.STANDARD, BassieOS.CENTER_WINDOW,
    BassieOS.CENTER_WINDOW, 30, 12, WindowMessageFunction)
