-- BassieOS_Info { type = 8, name = 'BassieOS', description = 'The BassieOS kernel and window manager', versionNumber = 30, versionString = '3.0', author = 'Bastiaan van der Plaat' }
if term == nil then
    print('This program needs ComputerCraft to run')
    return
end

if BassieOS ~= nil then
    print('BassieOS is already running or it crashed')
    print('Reset the computer by holding Ctrl+R and try again')
    return
end

-- ### BassieOS API ###
_G.BassieOS = {}

-- Utils functions
BassieOS.CheckProperty = function (property, part)
    if type(property) == 'number' and type(part) == 'number' then
        return bit.band(property, part) ~= 0
    end

    return nil
end

BassieOS.EllipseString = function (text, width, fill)
    if type(text) == 'string' and type(width) == 'number' and type(fill) == 'boolean' then
        if string.len(text) > width then
            return string.sub(text, 0, width - 2) .. '..'
        end

        if fill then
            return text .. string.rep(' ', width - string.len(text))
        else
            return text
        end
    end

    return nil
end

-- System functions
BassieOS.VERSION_NUMBER = 30
BassieOS.VERSION_STRING = '3.0'

BassieOS.CreateProcess = function (path, args)
    if type(path) == 'string' and fs.exists(path) and not fs.isDir(path) and (type(args) == 'table' or args == nil) then
        local file = fs.open(path, 'r')
        local program, error = load((args ~= nil and 'local args = textutils.unserialize([[' .. textutils.serialize(args) .. ']])\n' or '') .. file.readAll(), path)
        file.close()
        if program ~= nil then
            program()
            return true
        else
            BassieOS.CreateMessage('Error starting ' .. path, error)
        end
    end

    return false
end

BassieOS.ProgramInfoType = {}
BassieOS.ProgramInfoType.PROGRAM = 1
BassieOS.ProgramInfoType.APP = 2
BassieOS.ProgramInfoType.GAME = 4
BassieOS.ProgramInfoType.SYSTEM = 8

BassieOS.GetProgramInfo = function (path)
    if type(path) == 'string' and fs.exists(path) and not fs.isDir(path) then
        local file = fs.open(path, 'r')
        local first_line = file.readLine()
        file.close()

        local program_info_magic = '-- BassieOS_Info '
        if first_line ~= nil and string.sub(first_line, 0, string.len(program_info_magic)) == program_info_magic then
            return textutils.unserialize(string.sub(first_line, string.len(program_info_magic)))
        end
    end

    return nil
end

local running = true

BassieOS.IsRunning = function ()
    return running
end

BassieOS.StopRunning = function ()
    running = false
end

-- Bitmap functions
BassieOS.CreateBitmap = function (width, height, character, text_color, background_color)
    if character == nil then
        character = ' '
    end
    if text_color == nil then
        text_color = colors.black
    end
    if background_color == nil then
        background_color = colors.white
    end

    if
        type(width) == 'number' and type(height) == 'number' and type(character) == 'string' and
        type(text_color) == 'number' and type(background_color) == 'number'
    then
        local bitmap = {}
        bitmap.width = width
        bitmap.height = height

        bitmap.data = {}
        for y = 0, height - 1 do
            for x = 0, width - 1 do
                local position = (y * width + x) * 3
                bitmap.data[position] = string.byte(character)
                bitmap.data[position + 1] = text_color
                bitmap.data[position + 2] = background_color
            end
        end

        return bitmap
    end

    return nil
end

BassieOS.DrawCharacter = function (bitmap, x, y, character, text_color, background_color)
    if type(character) == 'string' then
        character = string.byte(character)
    end

    if
        type(bitmap) == 'table' and type(x) == 'number' and type(y) == 'number' and
        type(character) == 'number' and type(text_color) == 'number' and type(background_color) == 'number'
    then
        if
            x >= 0 and
            y >= 0 and
            x < bitmap.width and
            y < bitmap.height
        then
            local position = (y * bitmap.width + x) * 3
            bitmap.data[position] = character
            bitmap.data[position + 1] = text_color
            bitmap.data[position + 2] = background_color

            return true
        end
    end

    return false
end

BassieOS.BassieImageToBitmap = function (image)
    if type(image) == 'string' and string.sub(image, 0, 4) == 'BIMG' then
        local width = tonumber(string.sub(image, 5, 6), 16)
        local height = tonumber(string.sub(image, 7, 8), 16)

        local bitmap = BassieOS.CreateBitmap(width, height)

        local offset = 9
        for y = 0, height - 1 do
            for x = 0, width - 1 do
                BassieOS.DrawCharacter(bitmap, x, y, string.sub(image, offset, offset), 2 ^ tonumber(string.sub(image, offset + 1, offset + 1), 16), 2 ^ tonumber(string.sub(image, offset + 2, offset + 2), 16))
                offset = offset + 3
            end
        end

        return bitmap
    end

    return nil
end

BassieOS.BitmapToBassieImage = function (bitmap)
    if type(bitmap) == 'table' then
        local image = string.format("BIMG%02x%02x", bitmap.width, bitmap.height)

        for y = 0, bitmap.height - 1 do
            for x = 0, bitmap.width - 1 do
                local position = (y * bitmap.width + x) * 3
                image = image .. string.format(
                    '%s%1x%1x',
                    string.char(bitmap.data[position]),
                    math.log(bitmap.data[position + 1]) / math.log(2),
                    math.log(bitmap.data[position + 2]) / math.log(2)
                )
            end
        end

        return image
    end

    return nil
end

BassieOS.StrokeRect = function (bitmap, x, y, width, height, character, text_color, background_color)
    if
        type(bitmap) == 'table' and type(x) == 'number' and type(y) == 'number' and type(width) == 'number' and
        type(height) == 'number' and type(character) == 'string' and
        type(text_color) == 'number' and type(background_color) == 'number'
    then
        for other_y = 0, height - 1 do
            for other_x = 0, width - 1 do
                if
                    other_x == 0 or
                    other_y == 0 or
                    other_x == width - 1 or
                    other_y == height - 1
                then
                    BassieOS.DrawCharacter(bitmap, x + other_x, y + other_y, string.byte(character), text_color, background_color)
                end
            end
        end

        return true
    end

    return false
end

BassieOS.FillRect = function (bitmap, x, y, width, height, character, text_color, background_color)
    if
        type(bitmap) == 'table' and type(x) == 'number' and type(y) == 'number' and type(width) == 'number' and
        type(height) == 'number' and type(character) == 'string' and
        type(text_color) == 'number' and type(background_color) == 'number'
    then
        for other_y = 0, height - 1 do
            for other_x = 0, width - 1 do
                BassieOS.DrawCharacter(bitmap, x + other_x, y + other_y, string.byte(character), text_color, background_color)
            end
        end

        return true
    end

    return false
end

BassieOS.DrawText = function (bitmap, x, y, text, text_color, background_color)
    if
        type(bitmap) == 'table' and type(x) == 'number' and type(y) == 'number' and type(text) == 'string' and
        type(text_color) == 'number' and type(background_color) == 'number'
    then
        for i = 0, string.len(text) - 1 do
            BassieOS.DrawCharacter(bitmap, x + i, y, string.byte(text, i + 1), text_color, background_color)
        end

        return true
    end

    return false
end

BassieOS.DrawTextWrapped = function (bitmap, x, y, width, text, text_color, background_color)
    if
        type(bitmap) == 'table' and type(x) == 'number' and type(y) == 'number' and type(width) == 'number' and
        type(text) == 'string' and type(text_color) == 'number' and type(background_color) == 'number'
    then
        local other_x = 0
        local other_y = 0
        for i = 0, string.len(text) - 1 do
            if string.sub(text, i + 1, i + 1) == '\n' then
                other_x = 0
                other_y = other_y + 1
            else
                BassieOS.DrawCharacter(bitmap, x + other_x, y + other_y, string.byte(text, i + 1), text_color, background_color)

                if other_x == width - 1 then
                    other_x = 0
                    other_y = other_y + 1
                else
                    other_x = other_x + 1
                end
            end
        end

        return true
    end

    return false
end

BassieOS.DrawBitmap = function (bitmap, x, y, other_bitmap)
    if
        type(bitmap) == 'table' and type(other_bitmap) == 'table' and
        type(x) == 'number' and type(y) == 'number'
    then
        for other_y = 0, other_bitmap.height - 1 do
            for other_x = 0, other_bitmap.width - 1 do
                local position = (other_y * other_bitmap.width + other_x) * 3
                BassieOS.DrawCharacter(bitmap, x + other_x, y + other_y, other_bitmap.data[position], other_bitmap.data[position + 1], other_bitmap.data[position + 2])
            end
        end

        return true
    end

    return false
end

-- Screen functions
local screen = {}

local BeginScreen = function ()
    screen.old_text_color = term.getTextColor()
    screen.old_background_color = term.getBackgroundColor()

    screen.width, screen.height = term.getSize()
    screen.bitmap = BassieOS.CreateBitmap(screen.width, screen.height)

    screen.force_color_convertion = false
    screen.is_first_time = true
    screen.write_bitmap = BassieOS.CreateBitmap(screen.width, screen.height)

    screen.offset = {}
    screen.offset.top = 0
    screen.offset.left = 0
    screen.offset.right = 0
    screen.offset.bottom = 0
end

local UpdateScreen = function ()
    for y = 0, screen.height - 1 do
        for x = 0, screen.width - 1 do
            local position = (y * screen.width + x) * 3
            if
                screen.is_first_time or
                screen.bitmap.data[position] ~= screen.write_bitmap.data[position] or
                screen.bitmap.data[position + 1] ~= screen.write_bitmap.data[position + 1] or
                screen.bitmap.data[position + 2] ~= screen.write_bitmap.data[position + 2]
            then
                term.setCursorPos(x + 1, y + 1)

                if screen.force_color_convertion or not term.isColor() then
                    -- Convert text color to black and white
                    if
                        screen.bitmap.data[position + 1] >= colors.orange and
                        screen.bitmap.data[position + 1] <= colors.pink
                    then
                        term.setTextColor(colors.lightGray)
                    elseif
                        screen.bitmap.data[position + 1] >= colors.cyan and
                        screen.bitmap.data[position + 1] <= colors.red
                    then
                        term.setTextColor(colors.gray)
                    else
                        term.setTextColor(screen.bitmap.data[position + 1])
                    end

                    -- Convert background color to black and white
                    if
                        screen.bitmap.data[position + 2] >= colors.orange and
                        screen.bitmap.data[position + 2] <= colors.pink
                    then
                        term.setBackgroundColor(colors.lightGray)
                    elseif
                        screen.bitmap.data[position + 2] >= colors.cyan and
                        screen.bitmap.data[position + 2] <= colors.red
                    then
                        term.setBackgroundColor(colors.gray)
                    else
                        term.setBackgroundColor(screen.bitmap.data[position + 2])
                    end
                else
                    term.setTextColor(screen.bitmap.data[position + 1])
                    term.setBackgroundColor(screen.bitmap.data[position + 2])
                end

                term.write(string.char(screen.bitmap.data[position]))

                screen.write_bitmap.data[position] = screen.bitmap.data[position]
                screen.write_bitmap.data[position + 1] = screen.bitmap.data[position + 1]
                screen.write_bitmap.data[position + 2] = screen.bitmap.data[position + 2]
            end
            x = x + 1
        end
        y = y + 1
    end

    screen.is_first_time = false
end

local StopScreen = function ()
    term.setTextColor(screen.old_text_color)
    term.setBackgroundColor(screen.old_background_color)
    term.clear()
    term.setCursorPos(1, 1)
end

BassieOS.GetScreenWidth = function ()
    return screen.width
end

BassieOS.GetScreenHeight = function ()
    return screen.height
end

BassieOS.GetScreenBitmap = function ()
    return screen.bitmap
end

BassieOS.GetForceColorConvertion = function ()
    return screen.force_color_convertion
end

BassieOS.SetForceColorConvertion = function (force_color_convertion)
    if type(force_color_convertion) == 'boolean' then
        screen.force_color_convertion = force_color_convertion
        return true
    end
    return false
end

BassieOS.GetScreenOffsetTop = function ()
    return screen.offset.top
end

BassieOS.SetScreenOffsetTop = function (top)
    if type(top) == 'number' then
        screen.offset.top = top
    end
end

BassieOS.GetScreenOffsetLeft = function ()
    return screen.offset.left
end

BassieOS.SetScreenOffsetLeft = function (left)
    if type(left) == 'number' then
        screen.offset.left = left
    end
end

BassieOS.GetScreenOffsetRight = function ()
    return screen.offset.right
end

BassieOS.SetScreenOffsetRight = function (right)
    if type(right) == 'number' then
        screen.offset.right = right
    end
end

BassieOS.GetScreenOffsetBottom = function ()
    return screen.offset.bottom
end

BassieOS.SetScreenOffsetBottom = function (bottom)
    if type(bottom) == 'number' then
        screen.offset.bottom = bottom
    end
end

-- Window functions
local windows = {}
local windowIdCounter = 0
local window_order = {}

BassieOS.WindowStyle = {}
BassieOS.WindowStyle.VISIBLE = 1
BassieOS.WindowStyle.DECORATED = 2
BassieOS.WindowStyle.FOCUSABLE = 4
BassieOS.WindowStyle.RESIZABLE = 8
BassieOS.WindowStyle.LISTED = 16
BassieOS.WindowStyle.STANDARD = BassieOS.WindowStyle.LISTED + BassieOS.WindowStyle.RESIZABLE +
    BassieOS.WindowStyle.FOCUSABLE + BassieOS.WindowStyle.DECORATED + BassieOS.WindowStyle.VISIBLE
BassieOS.WindowStyle.TOPMOST = 32

BassieOS.WindowMessage = {}
BassieOS.WindowMessage.CREATE = 0
BassieOS.WindowMessage.CLOSE = 1
BassieOS.WindowMessage.DRAW = 2
BassieOS.WindowMessage.MOVE = 3
BassieOS.WindowMessage.SIZE = 4
BassieOS.WindowMessage.FOCUS = 5
BassieOS.WindowMessage.BLUR = 6
BassieOS.WindowMessage.BACK = 7
BassieOS.WindowMessage.KEY_CHAR = 8
BassieOS.WindowMessage.KEY_DOWN = 9
BassieOS.WindowMessage.KEY_UP = 10
BassieOS.WindowMessage.MOUSE_DOWN = 11
BassieOS.WindowMessage.MOUSE_UP = 12
BassieOS.WindowMessage.MOUSE_DRAG = 13

local GetWindow = function (window_id)
    for i = 1, #windows do
        local window = windows[i]
        if window.id == window_id then
            return window
        end
    end
    return nil
end

BassieOS.GetWindowIds = function ()
    local window_ids = {}
    for i = 1, #windows do
        local window = windows[i]
        window_ids[#window_ids + 1] = window.id
    end
    return window_ids
end

BassieOS.GetWindowOrder = function ()
    local window_ids = {}
    for i = 1, #window_order do
        window_ids[#window_ids + 1] = window_order[i]
    end
    return window_ids
end

BassieOS.GetFocusWindowId = function ()
    for i = 1, #window_order do
        local window_id = window_order[i]
        if
            BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.VISIBLE) and
            not BassieOS.IsWindowMinimized(window_id) and
            BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.FOCUSABLE)
        then
            return window_id
        end
    end
    return nil
end

BassieOS.CENTER_WINDOW = 0xffff
BassieOS.CreateWindow = function (title, style, x, y, width, height, message_function)
    if
        type(title) == 'string' and type(style) == 'number' and type(x) == 'number' and type(y) == 'number' and
        type(width) == 'number' and type(height) == 'number' and type(message_function) == 'function'
    then
        local window = {}

        window.id = windowIdCounter
        windowIdCounter = windowIdCounter + 1

        window.title = title
        window.style = style

        if x == BassieOS.CENTER_WINDOW then
            window.x = math.floor(((BassieOS.GetScreenWidth() - BassieOS.GetScreenOffsetLeft() - BassieOS.GetScreenOffsetRight()) - width) / 2) + BassieOS.GetScreenOffsetLeft()
        else
            window.x = x
        end
        if y == BassieOS.CENTER_WINDOW then
            window.y = math.floor(((BassieOS.GetScreenHeight() - BassieOS.GetScreenOffsetTop() - BassieOS.GetScreenOffsetBottom()) - height) / 2) + BassieOS.GetScreenOffsetTop()
        else
            window.y = y
        end

        window.width = width
        window.height = height

        window.min_width = BassieOS.CheckProperty(style, BassieOS.WindowStyle.RESIZABLE) and 4 or 3
        window.min_height = window.min_width - 1

        window.max_width = BassieOS.GetScreenWidth()
        window.max_height = BassieOS.GetScreenHeight()

        window.message_function = message_function

        window.bitmap = BassieOS.CreateBitmap(width, height)
        window.is_invalid = true

        window.is_focused = false
        window.is_minimized = false
        window.is_snapped = false
        window.is_maximized = false

        windows[#windows + 1] = window

        window_order[#window_order + 1] = window.id

        BassieOS.SendWindowMessage(window.id, BassieOS.WindowMessage.CREATE)

        if BassieOS.HasWindowStyle(window.id, BassieOS.WindowStyle.FOCUSABLE) then
            BassieOS.FocusWindow(window.id)
        end

        return window.id
    end

    return nil
end

BassieOS.GetWindowTitle = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.title
        end
    end
    return nil
end

BassieOS.SetWindowTitle = function (window_id, title)
    if type(window_id) == 'number' and type(title) == 'string' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.title = title
            return true
        end
    end
    return false
end

BassieOS.GetWindowStyle = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.style
        end
    end
    return nil
end

BassieOS.HasWindowStyle = function (window_id, style)
    if type(window_id) == 'number' and type(style) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return BassieOS.CheckProperty(window.style, style)
        end
    end
    return false
end

BassieOS.SetWindowStyle = function (window_id, style)
    if type(window_id) == 'number' and type(style) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.style = style
            return true
        end
    end
    return false
end

BassieOS.AddWindowStyle = function (window_id, style)
    if type(window_id) == 'number' and type(style) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.style = window.style + style
            return true
        end
    end
    return false
end

BassieOS.RemoveWindowStyle = function (window_id, style)
    if type(window_id) == 'number' and type(style) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.style = window.style - style
            return true
        end
    end
    return false
end

BassieOS.GetWindowX = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            if window.is_maximized then
                return BassieOS.GetScreenOffsetLeft()
            else
                return window.x
            end
        end
    end
    return nil
end

BassieOS.SetWindowX = function (window_id, x)
    if type(window_id) == 'number' and type(x) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.x = x
            BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.MOVE, window.x, window.y)
            return true
        end
    end
    return false
end

BassieOS.GetWindowY = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            if window.is_maximized then
                return BassieOS.GetScreenOffsetTop() + 1
            else
                return window.y
            end
        end
    end
    return nil
end

BassieOS.SetWindowY = function (window_id, y)
    if type(window_id) == 'number' and type(y) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.y = y
            BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.MOVE, window.x, window.y)
            return true
        end
    end
    return false
end

BassieOS.GetWindowWidth = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            if window.is_maximized then
                return BassieOS.GetScreenWidth() - BassieOS.GetScreenOffsetLeft() - BassieOS.GetScreenOffsetRight()
            else
                return window.width
            end
        end
    end
    return nil
end

BassieOS.SetWindowWidth = function (window_id, width)
    if type(window_id) == 'number' and type(width) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.width = width

            window.bitmap = BassieOS.CreateBitmap(window.width, window.height)
            window.is_invalid = true
            BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.SIZE, window.width, window.height)

            return true
        end
    end
    return false
end

BassieOS.GetWindowHeight = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            if window.is_maximized then
                return BassieOS.GetScreenHeight() - 1 - BassieOS.GetScreenOffsetTop() - BassieOS.GetScreenOffsetBottom()
            else
                return window.height
            end
        end
    end
    return nil
end

BassieOS.SetWindowHeight = function (window_id, height)
    if type(window_id) == 'number' and type(height) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.height = height

            window.bitmap = BassieOS.CreateBitmap(window.width, window.height)
            window.is_invalid = true
            BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.SIZE, window.width, window.height)

            return true
        end
    end
    return false
end

BassieOS.GetWindowMinWidth = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.min_width
        end
    end
    return nil
end

BassieOS.SetWindowMinWidth = function (window_id, min_width)
    if type(window_id) == 'number' and type(min_width) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.min_width = min_width
            return true
        end
    end
    return false
end

BassieOS.GetWindowMinHeight = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.min_height
        end
    end
    return nil
end

BassieOS.SetWindowMinHeight = function (window_id, min_height)
    if type(window_id) == 'number' and type(min_height) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.min_height = min_height
            return true
        end
    end
    return false
end

BassieOS.GetWindowMaxWidth = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.max_width
        end
    end
    return nil
end

BassieOS.SetWindowMaxWidth = function (window_id, max_width)
    if type(window_id) == 'number' and type(max_width) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.max_width = max_width
            return true
        end
    end
    return false
end

BassieOS.GetWindowMaxHeight = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.max_height
        end
    end
    return nil
end

BassieOS.SetWindowMaxHeight = function (window_id, max_height)
    if type(window_id) == 'number' and type(max_height) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.max_height = max_height
            return true
        end
    end
    return false
end

BassieOS.GetWindowBitmap = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.bitmap
        end
    end
    return nil
end

BassieOS.IsWindowInvalid = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.is_invalid
        end
    end
    return nil
end

BassieOS.InvalidWindow = function (window_id, is_invalid)
    if type(window_id) == 'number' and type(is_invalid) == 'boolean' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.is_invalid = is_invalid
            return true
        end
    end
    return false
end

BassieOS.IsWindowFocused = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.is_focused
        end
    end
    return nil
end

BassieOS.FocusWindow = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            if not window.is_focused then
                -- Remove focus of focus window
                local focus_window_id = BassieOS.GetFocusWindowId()
                if focus_window_id ~= nil then
                    local focus_window = GetWindow(focus_window_id)
                    focus_window.is_focused = false
                    BassieOS.SendWindowMessage(focus_window_id, BassieOS.WindowMessage.BLUR)
                end

                -- Give focus to window
                window.is_focused = true
                BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.FOCUS)

                -- Update window order
                local new_window_order = {}

                if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.TOPMOST) then
                    new_window_order[#new_window_order + 1] = window_id
                end

                for i = 1, #window_order do
                    local other_window_id = window_order[i]
                    if BassieOS.HasWindowStyle(other_window_id, BassieOS.WindowStyle.TOPMOST) and other_window_id ~= window_id then
                        new_window_order[#new_window_order + 1] = other_window_id
                    end
                end

                if not BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.TOPMOST) then
                    new_window_order[#new_window_order + 1] = window_id
                end

                for i = 1, #window_order do
                    local other_window_id = window_order[i]
                    if not BassieOS.HasWindowStyle(other_window_id, BassieOS.WindowStyle.TOPMOST) and other_window_id ~= window_id then
                        new_window_order[#new_window_order + 1] = other_window_id
                    end
                end

                window_order = new_window_order
            end
        end
    end
    return nil
end

BassieOS.IsWindowMinimized = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.is_minimized
        end
    end
    return nil
end

BassieOS.MinimizeWindow = function (window_id, is_minimized)
    if type(window_id) == 'number' and type(is_minimized) == 'boolean' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.is_focused = false
            window.is_minimized = is_minimized

            if is_minimized then
                BassieOS.FocusWindow(BassieOS.GetFocusWindowId())
            elseif BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.FOCUSABLE) then
                BassieOS.FocusWindow(window_id)
            end

            return true
        end
    end
    return false
end

BassieOS.IsWindowSnapped = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.is_snapped
        end
    end
    return nil
end

BassieOS.SnapWindow = function (window_id, is_snapped)
    if type(window_id) == 'number' and type(is_snapped) == 'boolean' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.is_snapped = is_snapped
            return true
        end
    end
    return false
end

BassieOS.IsWindowMaximized = function (window_id)
    if type(window_id) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            return window.is_maximized
        end
    end
    return nil
end

BassieOS.MaximizeWindow = function (window_id, is_maximized)
    if type(window_id) == 'number' and type(is_maximized) == 'boolean' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.is_maximized = is_maximized

            BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.MOVE, BassieOS.GetWindowX(window_id), BassieOS.GetWindowY(window_id))

            window.bitmap = BassieOS.CreateBitmap(BassieOS.GetWindowWidth(window_id), BassieOS.GetWindowHeight(window_id))
            window.is_invalid = true
            BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.SIZE, BassieOS.GetWindowWidth(window_id), BassieOS.GetWindowHeight(window_id))

            return true
        end
    end
    return false
end

BassieOS.SendWindowMessage = function (window_id, message, param1, param2, param3, param4)
    if type(window_id) == 'number' and type(message) == 'number' then
        local window = GetWindow(window_id)
        if window ~= nil then
            window.message_function(window_id, message, param1, param2, param3, param4)
            return true
        end
    end
    return false
end

BassieOS.CloseWindow = function (window_id)
    if type(window_id) == 'number' then
        for i = 1, #windows do
            local window = windows[i]
            if window.id == window_id then
                -- Send close message
                BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.CLOSE)

                -- Remove window object from windows
                table.remove(windows, i)

                -- Remove window id from window order
                local new_window_order = {}
                for j = 1, #window_order do
                    local other_window_id = window_order[j]
                    if other_window_id ~= window_id then
                        new_window_order[#new_window_order + 1] = other_window_id
                    end
                end
                window_order = new_window_order

                -- Focus new window
                BassieOS.FocusWindow(BassieOS.GetFocusWindowId())

                return true
            end
        end
    end
    return false
end

BassieOS.CreateMessage = function (title, text)
    if type(title) == 'string' and type(text) == 'string' then
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

                -- Draw text
                BassieOS.DrawTextWrapped(bitmap, 1, 1, width - 2, text, text_color, background_color)
            end
        end

        local line = ''
        local max_line = ''
        local lines = 1
        for i = 1, #text do
            local char = string.sub(text, i, i)
            if char == '\n' then
                line = ''
                if string.len(line) > string.len(max_line) then
                    max_line = line
                end
                lines = lines + 1
            else
                line = line .. char
            end
        end
        if max_line == '' then
            max_line = line
        end

        BassieOS.CreateWindow(title, BassieOS.WindowStyle.STANDARD - BassieOS.WindowStyle.RESIZABLE, BassieOS.CENTER_WINDOW, BassieOS.CENTER_WINDOW, string.len(max_line) + 4, lines + 2, WindowMessageFunction)
    end
end

-- Theme functions
BassieOS.Theme = {}
BassieOS.Theme.LIGHT = 0
BassieOS.Theme.DARK = 1

local system_theme = BassieOS.Theme.DARK

BassieOS.GetTheme = function ()
    return system_theme
end

BassieOS.SetTheme = function (theme)
    if type(theme) == 'number' then
        if system_theme ~= theme then
            system_theme = theme

            for i = 1, #window_order do
                local window_id = window_order[i]
                BassieOS.InvalidWindow(window_id, true)
            end
        end
        return true
    end
    return false
end

-- ### Window Manager ###

-- Begin screen
BeginScreen()

-- Start system bar process
BassieOS.CreateProcess('/bar.lua')

-- Event loop
local window_drag = {}
window_drag.is_enabled = false

local window_resize = {}
window_resize.is_enabled = false
window_resize.is_north = false
window_resize.is_west = false
window_resize.is_east = false
window_resize.is_south = false

while running do
    local event, param1, param2, param3 = os.pullEvent()

    -- Handle window
    if screen.is_first_time or event == 'timer' then
        local screen_bitmap = BassieOS.GetScreenBitmap()

        -- Draw background color
        BassieOS.FillRect(screen_bitmap, 0, 0, BassieOS.GetScreenWidth(), BassieOS.GetScreenHeight(), '.', colors.white, colors.blue)

        -- Draw windows
        local window_order = BassieOS.GetWindowOrder()
        for i = #window_order, 1, -1 do
            window_id = window_order[i]

            if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.VISIBLE) and not BassieOS.IsWindowMinimized(window_id) then
                local window_x = BassieOS.GetWindowX(window_id)
                local window_y = BassieOS.GetWindowY(window_id)
                local window_width = BassieOS.GetWindowWidth(window_id)
                local window_height = BassieOS.GetWindowHeight(window_id)
                local window_bitmap = BassieOS.GetWindowBitmap(window_id)

                -- Draw window decoration
                if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.DECORATED) then
                    local window_title = BassieOS.GetWindowTitle(window_id)

                    local border_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.lightGray or colors.black
                    local text_color
                    local icon_color
                    if BassieOS.IsWindowFocused(window_id) then
                        text_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.black or colors.white
                        icon_color = colors.white
                    else
                        text_color = BassieOS.GetTheme() == BassieOS.Theme.LIGHT and colors.gray or colors.lightGray
                        icon_color = colors.lightGray
                    end

                    BassieOS.StrokeRect(screen_bitmap, window_x - 1, window_y - 1, window_width + 2, window_height + 2, ' ', text_color, border_color)

                    BassieOS.DrawText(screen_bitmap, window_x, window_y - 1, '<', icon_color, colors.blue)

                    local window_title_width = window_width - 2 - (BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.RESIZABLE) and 4 or 3)
                    if window_title_width >= 2 then
                        local window_title_ellipsed = BassieOS.EllipseString(window_title, window_title_width, false)
                        BassieOS.DrawText(screen_bitmap, window_x + 2 + math.floor((window_title_width - string.len(window_title_ellipsed)) / 2), window_y - 1, window_title_ellipsed, text_color, border_color)
                    end

                    if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.RESIZABLE) then
                        BassieOS.DrawText(screen_bitmap, window_x + window_width - 3, window_y - 1, '_', icon_color, colors.orange)

                        BassieOS.DrawText(screen_bitmap, window_x + window_width - 2, window_y - 1, BassieOS.IsWindowMaximized(window_id) and 'o' or 'O', icon_color, colors.green)
                    else
                        BassieOS.DrawText(screen_bitmap, window_x + window_width - 2, window_y - 1, '_', icon_color, colors.orange)
                    end

                    BassieOS.DrawText(screen_bitmap, window_x + window_width - 1, window_y - 1, 'X', icon_color, colors.red)
                end

                -- Draw window bitmap
                if BassieOS.IsWindowInvalid(window_id) then
                    BassieOS.InvalidWindow(window_id, false)
                    BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.DRAW, window_bitmap, window_width, window_height)
                end
                BassieOS.DrawBitmap(screen_bitmap, window_x, window_y, window_bitmap)
            end
        end

        -- Update screen
        UpdateScreen()

        os.startTimer(1 / 20)
    end

    -- Handle mouse down events
    if event == 'mouse_click' then
        local button = param1
        local x = param2 - 1
        local y = param3 - 1

        local window_order = BassieOS.GetWindowOrder()
        for i = 1, #window_order do
            local window_id = window_order[i]

            if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.VISIBLE) and not BassieOS.IsWindowMinimized(window_id) then
                local window_x = BassieOS.GetWindowX(window_id)
                local window_y = BassieOS.GetWindowY(window_id)
                local window_width = BassieOS.GetWindowWidth(window_id)
                local window_height = BassieOS.GetWindowHeight(window_id)

                if
                    x >= window_x and
                    y >= window_y and
                    x < window_x + window_width and
                    y < window_y + window_height
                then
                    if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.FOCUSABLE) then
                        BassieOS.FocusWindow(window_id)
                    end

                    BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.MOUSE_DOWN, button, x - window_x, y - window_y)
                    break
                end

                if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.DECORATED) then
                    if
                        x >= window_x - 1 and
                        y >= window_y - 1 and
                        x <= window_x + window_width and
                        y <= window_y + window_height
                    then
                        if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.FOCUSABLE) then
                            BassieOS.FocusWindow(window_id)
                        end

                        -- Window title
                        if
                            x >= window_x + 2 and
                            x <= window_x + window_width - (BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.RESIZABLE) and 5 or 4) and
                            y == window_y - 1
                        then
                            window_drag.is_enabled = true
                            window_drag.window_id = window_id
                            window_drag.offset_x = x - window_x
                        end

                        if
                            BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.RESIZABLE) and
                            not BassieOS.IsWindowMaximized(window_id)
                        then
                            -- Top resize border
                            if
                                (
                                    x == window_x - 1 or
                                    x == window_x + 1 or
                                    x == window_x + window_width - (BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.RESIZABLE) and 4 or 3) or
                                    x == window_x + window_width
                                ) and
                                y == window_y - 1
                            then
                                window_resize.is_enabled = true
                                window_resize.is_north = true
                            end

                            -- Left resize border
                            if
                                x == window_x - 1 and
                                y >= window_y - 1 and
                                y <= window_y + window_height
                            then
                                window_resize.is_enabled = true
                                window_resize.is_west = true
                            end

                            -- Right resize border
                            if
                                x == window_x + window_width and
                                y >= window_y - 1 and
                                y <= window_y + window_height
                            then
                                window_resize.is_enabled = true
                                window_resize.is_east = true
                            end

                            -- Bottom resize border
                            if
                                x >= window_x - 1 and
                                x <= window_x + window_width and
                                y == window_y + window_height
                            then
                                window_resize.is_enabled = true
                                window_resize.is_south = true
                            end

                            -- Resize save old window rect
                            if window_resize.is_enabled then
                                window_resize.window_id = window_id
                                window_resize.old_x = window_x
                                window_resize.old_y = window_y
                                window_resize.old_width = window_width
                                window_resize.old_height = window_height
                            end
                        end

                        break
                    end
                end
            end
        end
    end

    -- Handle mouse drag events
    if event == 'mouse_drag' then
        local button = param1
        local x = param2 - 1
        local y = param3 - 1

        if window_drag.is_enabled then
            local window_half_screen_width = math.floor((BassieOS.GetScreenWidth() - BassieOS.GetScreenOffsetLeft() - BassieOS.GetScreenOffsetRight()) / 2)

            -- Left border snap
            if
                BassieOS.HasWindowStyle(window_drag.window_id, BassieOS.WindowStyle.RESIZABLE) and
                x <= BassieOS.GetScreenOffsetLeft()
            then
                window_drag.is_enabled = false
                BassieOS.SnapWindow(window_drag.window_id, true)
                BassieOS.SetWindowX(window_drag.window_id, BassieOS.GetScreenOffsetLeft())
                BassieOS.SetWindowY(window_drag.window_id, BassieOS.GetScreenOffsetTop() + 1)
                BassieOS.SetWindowWidth(window_drag.window_id, window_half_screen_width)
                BassieOS.SetWindowHeight(window_drag.window_id, BassieOS.GetScreenHeight() - 1 - BassieOS.GetScreenOffsetTop() - BassieOS.GetScreenOffsetBottom())

            -- Right border snap
            elseif
                BassieOS.HasWindowStyle(window_drag.window_id, BassieOS.WindowStyle.RESIZABLE) and
                x >= BassieOS.GetScreenWidth() - 1 - BassieOS.GetScreenOffsetRight()
            then
                window_drag.is_enabled = false
                BassieOS.SnapWindow(window_drag.window_id, true)
                BassieOS.SetWindowX(window_drag.window_id, BassieOS.GetScreenOffsetLeft() + window_half_screen_width + 1)
                BassieOS.SetWindowY(window_drag.window_id, BassieOS.GetScreenOffsetTop() + 1)
                BassieOS.SetWindowWidth(window_drag.window_id, window_half_screen_width)
                BassieOS.SetWindowHeight(window_drag.window_id, BassieOS.GetScreenHeight() - 1 - BassieOS.GetScreenOffsetTop() - BassieOS.GetScreenOffsetBottom())

            -- Top and bottom border maximize snap
            elseif
                BassieOS.HasWindowStyle(window_drag.window_id, BassieOS.WindowStyle.RESIZABLE) and
                not BassieOS.IsWindowSnapped(window_drag.window_id) and
                (
                    y <= BassieOS.GetScreenOffsetTop() or
                    y >= BassieOS.GetScreenHeight() - 1 - BassieOS.GetScreenOffsetBottom()
                )
            then
                window_drag.is_enabled = false
                BassieOS.MaximizeWindow(window_drag.window_id, true)

            -- Normal drag
            else
                if BassieOS.IsWindowMaximized(window_drag.window_id) then
                    BassieOS.MaximizeWindow(window_drag.window_id, false)
                    window_drag.offset_x = math.floor(BassieOS.GetWindowWidth(window_drag.window_id) / 2)
                end

                if
                    BassieOS.IsWindowSnapped(window_drag.window_id) and
                    y >= BassieOS.GetScreenOffsetTop() + 1
                then
                    BassieOS.SnapWindow(window_drag.window_id, false)
                end

                BassieOS.SetWindowX(window_drag.window_id, x - window_drag.offset_x)
                BassieOS.SetWindowY(window_drag.window_id, y + 1)
            end
        elseif window_resize.is_enabled then
            -- North window border resize
            if window_resize.is_north then
                local new_height = window_resize.old_height + (window_resize.old_y - (y + 1))
                if
                    new_height >= BassieOS.GetWindowMinHeight(window_resize.window_id) and
                    new_height <= BassieOS.GetWindowMaxHeight(window_resize.window_id)
                then
                    BassieOS.SetWindowY(window_resize.window_id, y + 1)
                    BassieOS.SetWindowHeight(window_resize.window_id, new_height)
                end
            end

            -- West window border resize
            if window_resize.is_west then
                local new_width = window_resize.old_width + (window_resize.old_x - (x + 1))
                if
                    new_width >= BassieOS.GetWindowMinWidth(window_resize.window_id) and
                    new_width <= BassieOS.GetWindowMaxWidth(window_resize.window_id)
                then
                    BassieOS.SetWindowX(window_resize.window_id, x + 1)
                    BassieOS.SetWindowWidth(window_resize.window_id, new_width)
                end
            end

            -- East window border resize
            if window_resize.is_east then
                local new_width = window_resize.old_width + (x - (window_resize.old_x + window_resize.old_width))
                if
                    new_width >= BassieOS.GetWindowMinWidth(window_resize.window_id) and
                    new_width <= BassieOS.GetWindowMaxWidth(window_resize.window_id)
                then
                    BassieOS.SetWindowWidth(window_resize.window_id, new_width)
                end
            end

            -- South window border resize
            if window_resize.is_south then
                local new_height = window_resize.old_height + (y - (window_resize.old_y + window_resize.old_height))
                if
                    new_height >= BassieOS.GetWindowMinHeight(window_resize.window_id) and
                    new_height <= BassieOS.GetWindowMaxHeight(window_resize.window_id)
                then
                    BassieOS.SetWindowHeight(window_resize.window_id, new_height)
                end
            end
        else
            local window_order = BassieOS.GetWindowOrder()
            for i = 1, #window_order do
                local window_id = window_order[i]

                if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.VISIBLE) and not BassieOS.IsWindowMinimized(window_id) then
                    local window_x = BassieOS.GetWindowX(window_id)
                    local window_y = BassieOS.GetWindowY(window_id)
                    local window_width = BassieOS.GetWindowWidth(window_id)
                    local window_height = BassieOS.GetWindowHeight(window_id)

                    if
                        x >= window_x and
                        y >= window_y and
                        x < window_x + window_width and
                        y < window_y + window_height
                    then
                        BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.MOUSE_DRAG, button, x - window_x, y - window_y)
                        break
                    end
                end
            end
        end
    end

    -- Handle mouse up events
    if event == 'mouse_up' then
        local button = param1
        local x = param2 - 1
        local y = param3 - 1

        if window_drag.is_enabled then
            window_drag.is_enabled = false
        elseif window_resize.is_enabled then
            window_resize.is_enabled = false
            window_resize.is_north = false
            window_resize.is_west = false
            window_resize.is_east = false
            window_resize.is_south = false
        else
            local window_order = BassieOS.GetWindowOrder()
            for i = 1, #window_order do
                local window_id = window_order[i]

                if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.VISIBLE) and not BassieOS.IsWindowMinimized(window_id) then
                    local window_x = BassieOS.GetWindowX(window_id)
                    local window_y = BassieOS.GetWindowY(window_id)
                    local window_width = BassieOS.GetWindowWidth(window_id)
                    local window_height = BassieOS.GetWindowHeight(window_id)

                    if
                        x >= window_x and
                        y >= window_y and
                        x < window_x + window_width and
                        y < window_y + window_height
                    then
                        BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.MOUSE_UP, button, x - window_x, y - window_y)
                        break
                    end

                    if BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.DECORATED) then
                        -- Back button
                        if
                            x == window_x and
                            y == window_y - 1
                        then
                            BassieOS.SendWindowMessage(window_id, BassieOS.WindowMessage.BACK)
                            break
                        end

                        -- Minimize button
                        if
                            x == window_x + window_width - (BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.RESIZABLE) and 3 or 2) and
                            y == window_y - 1
                        then
                            BassieOS.MinimizeWindow(window_id, true)
                            break
                        end

                        -- Maximize button
                        if
                            BassieOS.HasWindowStyle(window_id, BassieOS.WindowStyle.RESIZABLE) and
                            x == window_x + window_width - 2 and
                            y == window_y - 1
                        then
                            BassieOS.MaximizeWindow(window_id, not BassieOS.IsWindowMaximized(window_id))
                            break
                        end

                        -- Close button
                        if
                            x == window_x + window_width - 1 and
                            y == window_y - 1
                        then
                            BassieOS.CloseWindow(window_id)
                            break
                        end
                    end
                end
            end
        end
    end

    -- Handle key events
    local focus_window_id = BassieOS.GetFocusWindowId()
    if event == 'char' and focus_window_id ~= nil then
        BassieOS.SendWindowMessage(focus_window_id, BassieOS.WindowMessage.KEY_CHAR, param1)
    end

    if event == 'key' and focus_window_id ~= nil then
        BassieOS.SendWindowMessage(focus_window_id, BassieOS.WindowMessage.KEY_DOWN, param1, param2)
    end

    if event == 'key_up' and focus_window_id ~= nil then
        BassieOS.SendWindowMessage(focus_window_id, BassieOS.WindowMessage.KEY_UP, param1)
    end
end

-- Stop screen
StopScreen()

-- Stop global API
_G.BassieOS = nil
