-- !!BassieOS_INFO!! { type = 8, name = "BassieOS", version = 2, author = "Bastiaan van der Plaat <bastiaan.v.d.plaat@gmail.com>" }

-- BassieOS - A simple Operating System for the MineCraft ComputerCraft advanced color computer
-- Made by Bastiaan van der Plaat (https://github.com/bplaat)

local screen_width, screen_height = term.getSize()
local windows = {}
local windows_order = {}
local window_focus
local running = true

_G.BASSIEOS_VERSION = 2
_G.BASSIEOS_INFO_MAGIC = "-- !!BassieOS_INFO!! "
_G.BASSIEOS_IMAGE_MAGIC = "BIMG"

_G.BASSIEOS_INFO_TYPE_PROGRAM = 1
_G.BASSIEOS_INFO_TYPE_APP = 2
_G.BASSIEOS_INFO_TYPE_GAME = 4
_G.BASSIEOS_INFO_TYPE_SYSTEM = 8

_G.WINDOW_USE_DEFAULT = 10000

_G.WINDOW_EVENT_CREATE = 1
_G.WINDOW_EVENT_CLOSE = 2
_G.WINDOW_EVENT_PAINT = 3
_G.WINDOW_EVENT_MOVE = 4
_G.WINDOW_EVENT_SIZE = 5
_G.WINDOW_EVENT_FOCUS = 6
_G.WINDOW_EVENT_LOST_FOCUS = 7
_G.WINDOW_EVENT_KEY_DOWN = 8
_G.WINDOW_EVENT_KEY_UP = 9
_G.WINDOW_EVENT_MOUSE_DOWN = 10
_G.WINDOW_EVENT_MOUSE_UP = 11
_G.WINDOW_EVENT_MOUSE_DRAG = 12
_G.WINDOW_EVENT_MENU = 13

_G.WINDOW_STYLE_VISIBLE = 1
_G.WINDOW_STYLE_DECORATED = 2
_G.WINDOW_STYLE_FOCUSABLE = 4
_G.WINDOW_STYLE_RESIZABLE = 8
_G.WINDOW_STYLE_LISTED = 16
_G.WINDOW_STYLE_STANDARD = WINDOW_STYLE_LISTED + WINDOW_STYLE_RESIZABLE + WINDOW_STYLE_FOCUSABLE + WINDOW_STYLE_DECORATED + WINDOW_STYLE_VISIBLE
_G.WINDOW_STYLE_TOPMOST = 32

function _G.CheckOnion(onion, property)
    if type(onion) == "number" and type(property) == "number" then
        return bit.band(onion, property) ~= 0
    end
end

function _G.CutString(text, width)
    if type(text) == "string" and type(width) == "number" then
        if string.len(text) > width then
            return string.sub(text, 0, width - 2) .. ".."
        end
        return text .. string.rep(" ", width - string.len(text))
    end
end

function _G.RunProgram(path, args)
    if type(path) == "string" and (type(args) == "table" or args == nil) and fs.exists(path) and not fs.isDir(path) then
        local file = fs.open(path, "r")
        local program, err = load((args ~= nil and "local args = textutils.unserialize([[" .. textutils.serialize(args) .. "]])\n" or "") .. file.readAll(), path)
        file.close()
        if program ~= nil then
            program()
        else
            CreateMessage(err, err)
        end
    end
end

function _G.GetProgramInfo(path)
    if type(path) == "string" and fs.exists(path) and not fs.isDir(path) then
        local file = fs.open(path, "r")
        local first_line = file.readLine()
        file.close()
        if string.sub(first_line, 0, string.len(BASSIEOS_INFO_MAGIC)) == BASSIEOS_INFO_MAGIC then
            return textutils.unserialize(string.sub(first_line, string.len(BASSIEOS_INFO_MAGIC)))
        end
    end
end

function _G.GetScreenWidth()
    return screen_width
end

function _G.GetScreenHeight()
    return screen_height
end

function _G.GetWindows()
    local windows_ids = {}
    for i = 1, #windows do
        if not windows[i].closed then
            windows_ids[#windows_ids + 1] = i
        end
    end
    return windows_ids
end

function _G.GetWindowsOrder()
    return windows_order
end

function _G.GetFocusWindow()
    return window_focus
end

function _G.IsRunning()
    return running
end

function _G.CreateWindow(title, x, y, width, height, event_function)
    if type(title) == "string" and type(x) == "number" and type(y) == "number" and type(width) == "number" and type(height) == "number" and type(event_function) == "function" then
        local window_id = #windows + 1
        windows[window_id] = {
            title = title, style = WINDOW_STYLE_STANDARD,
            x = x == WINDOW_USE_DEFAULT and math.floor((GetScreenWidth() - width) / 2) or x,
            y = y == WINDOW_USE_DEFAULT and math.floor((GetScreenHeight() - height - 1) / 2) or y,
            width = width, height = height, event_function = event_function, minimized = false, maximized = false, closed = false
        }
        windows_order[#windows_order + 1] = window_id
        FocusWindow(window_id)
        SendWindowEvent(window_id, WINDOW_EVENT_CREATE)
        return window_id
    end
end

function _G.GetWindowTitle(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil then
        return windows[window_id].title
    end
end

function _G.SetWindowTitle(window_id, title)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(title) == "string" and windows[window_id].title ~= title then
        windows[window_id].title = title
    end
end

function _G.GetWindowStyle(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil then
        return windows[window_id].style
    end
end

function _G.HasWindowStyle(window_id, style)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(style) == "number" then
        return CheckOnion(windows[window_id].style, style)
    end
end

function _G.SetWindowStyle(window_id, style)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(style) == "number" and windows[window_id].style ~= style then
        windows[window_id].style = style
        FocusWindow(window_id)
    end
end

function _G.AddWindowStyle(window_id, style)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(style) == "number" and not HasWindowStyle(window_id, style) then
        windows[window_id].style = windows[window_id].style + style
        FocusWindow(window_id)
    end
end

function _G.RemoveWindowStyle(window_id, style)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(style) == "number" and HasWindowStyle(window_id, style) then
        windows[window_id].style = windows[window_id].style - style
        FocusWindow(window_id)
    end
end

function _G.GetWindowX(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil then
        return windows[window_id].maximized and 0 or windows[window_id].x
    end
end

function _G.SetWindowX(window_id, x)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(x) == "number" and windows[window_id].x ~= x then
        windows[window_id].x = x
        SendWindowEvent(window_id, WINDOW_EVENT_MOVE)
    end
end

function _G.GetWindowY(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil then
        return windows[window_id].maximized and 1 or windows[window_id].y
    end
end

function _G.SetWindowY(window_id, y)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(y) == "number" and windows[window_id].y ~= y then
        windows[window_id].y = y
        SendWindowEvent(window_id, WINDOW_EVENT_MOVE)
    end
end

function _G.GetWindowWidth(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil then
        return windows[window_id].maximized and GetScreenWidth() or windows[window_id].width
    end
end

function _G.SetWindowWidth(window_id, width)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(width) == "number" and windows[window_id].width ~= width then
        windows[window_id].width = width
        SendWindowEvent(window_id, WINDOW_EVENT_SIZE)
    end
end

function _G.GetWindowHeight(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil then
        return windows[window_id].maximized and GetScreenHeight() - 2 or windows[window_id].height
    end
end

function _G.SetWindowHeight(window_id, height)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(height) == "number" and windows[window_id].height ~= height then
        windows[window_id].height = height
        SendWindowEvent(window_id, WINDOW_EVENT_SIZE)
    end
end

function _G.SendWindowEvent(window_id, event, param1, param2, param3)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(event) == "number" then
        windows[window_id].event_function(window_id, event, param1, param2, param3)
    end
end

function _G.IsWindowMinimized(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil then
        return windows[window_id].minimized
    end
end

function _G.MinimizeWindow(window_id, minimized)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(minimized) == "boolean" then
        windows[window_id].minimized = minimized
        if not minimized then
            FocusWindow(window_id)
        else
            CheckWindowFocus()
        end
    end
end

function _G.IsWindowMaximized(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil then
        return windows[window_id].maximized
    end
end

function _G.MaximizeWindow(window_id, maximized)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(maximized) == "boolean" then
        windows[window_id].maximized = maximized
        SendWindowEvent(window_id, WINDOW_EVENT_SIZE)
        FocusWindow(window_id)
    end
end

function _G.IsWindowClosed(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil then
        return windows[window_id].closed
    end
end

function _G.CloseWindow(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil and not windows[window_id].closed then
        SendWindowEvent(window_id, WINDOW_EVENT_CLOSE)
        windows[window_id].closed = true

        local new_windows_order = {}
        for i = 1, #windows_order do
            if windows_order[i] ~= window_id then
                new_windows_order[#new_windows_order + 1] = windows_order[i]
            end
        end
        windows_order = new_windows_order

        CheckWindowFocus()
    end
end

function _G.CheckWindowFocus()
    local old_window_focus = window_focus

    local new_window_focus
    for i = 1, #windows_order do
        if HasWindowStyle(windows_order[i], WINDOW_STYLE_VISIBLE) and HasWindowStyle(windows_order[i], WINDOW_STYLE_FOCUSABLE) and not IsWindowMinimized(windows_order[i]) then
            new_window_focus = windows_order[i]
            break
        end
    end
    window_focus = new_window_focus

    if old_window_focus ~= window_focus then
        if old_window_focus ~= nil and not IsWindowClosed(old_window_focus) then
            SendWindowEvent(old_window_focus, WINDOW_EVENT_LOST_FOCUS)
        end
        if windows_focus ~= nil then
            SendWindowEvent(window_focus, WINDOW_EVENT_FOCUS)
        end
    end
end

function _G.FocusWindow(window_id)
    if type(window_id) == "number" and windows[window_id] ~= nil then
        if HasWindowStyle(window_id, WINDOW_STYLE_TOPMOST) then
            local new_windows_order = {}

            new_windows_order[#new_windows_order + 1] = window_id

            for i = 1, #windows_order do
                if HasWindowStyle(windows_order[i], WINDOW_STYLE_TOPMOST) and windows_order[i] ~= window_id then
                    new_windows_order[#new_windows_order + 1] = windows_order[i]
                end
            end

            for i = 1, #windows_order do
                if not HasWindowStyle(windows_order[i], WINDOW_STYLE_TOPMOST) then
                    new_windows_order[#new_windows_order + 1] = windows_order[i]
                end
            end

            windows_order = new_windows_order
        else
            local new_windows_order = {}

            for i = 1, #windows_order do
                if HasWindowStyle(windows_order[i], WINDOW_STYLE_TOPMOST) then
                    new_windows_order[#new_windows_order + 1] = windows_order[i]
                end
            end

            new_windows_order[#new_windows_order + 1] = window_id

            for i = 1, #windows_order do
                if not HasWindowStyle(windows_order[i], WINDOW_STYLE_TOPMOST) and windows_order[i] ~= window_id then
                    new_windows_order[#new_windows_order + 1] = windows_order[i]
                end
            end

            windows_order = new_windows_order
        end

        CheckWindowFocus()
    end
end

function _G.CreateMessage(title, text)
    if type(title) == "string" and type(text) == "string" then
        local function MessageEventFunction(window_id, event, param1, param2, param3)
            if event == WINDOW_EVENT_PAINT then
                DrawWindowText(window_id, text, 1, 1)
            end
        end
        CreateWindow(title, WINDOW_USE_DEFAULT, WINDOW_USE_DEFAULT, string.len(text) + 2, 3, MessageEventFunction)
    end
end

function _G.SetColor(text_color, background_color)
    if type(text_color) == "number" and type(background_color) == "number" then
        term.setTextColor(text_color)
        term.setBackgroundColor(background_color)
    end
end

function _G.GetTextColor()
    return term.getTextColor()
end

function _G.SetTextColor(text_color)
    if type(text_color) == "number" then
        term.setTextColor(text_color)
    end
end

function _G.GetBackgroundColor()
    return term.getBackgroundColor()
end
function _G.SetBackgroundColor(background_color)
    if type(background_color) == "number" then
        term.setBackgroundColor(background_color)
    end
end


function _G.DrawText(text, x, y)
    if type(text) == "string" and type(x) == "number" and type(y) == "number" then
        term.setCursorPos(x + 1, y + 1)
        term.write(text)
    end
end

function _G.DrawWindowText(window_id, text, x, y)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(text) == "string" and type(x) == "number" and type(y) == "number" then
        term.setCursorPos(GetWindowX(window_id) + x + 1, GetWindowY(window_id) + y + 1)
        term.write(text)
    end
end

function _G.CheckWindowMenuClick(window_id, menu, x, y)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(menu) == "table" and type(x) == "number" and type(y) == "number" then
        local offset = 0
        for i = 1, #menu do
            if x >= offset and x < offset + string.len(menu[i]) and y == 0 then
                SendWindowEvent(window_id, WINDOW_EVENT_MENU, i)
                return
            end
            offset = offset + string.len(menu[i]) + 1
        end
    end
end

function _G.DrawWindowMenu(window_id, menu)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(menu) == "table" then
        SetColor(colors.white, window_id == window_focus and colors.gray or colors.lightGray)
        DrawWindowText(window_id, string.rep(" ", GetWindowWidth(window_id)), 0, 0)
        local offset = 0
        for i = 1, #menu do
            DrawWindowText(window_id, menu[i], offset, 0)
            offset = offset + string.len(menu[i]) + 1
        end
        SetColor(colors.black, colors.white)
    end
end


function _G.DrawImage(image, x, y, image_width, image_height)
    if type(image) == "string" and string.sub(image, 0, 4) == BASSIEOS_IMAGE_MAGIC and type(x) == "number" and type(y) == "number" and (type(image_width) == "number" or image_width == nil) and (type(image_height) == "number" or image_height == nil) then
        if image_width == nil then image_width = tonumber(string.sub(image, 5, 6), 16) end
        if image_height == nil then image_height = tonumber(string.sub(image, 7, 8), 16) end
        local text_color = GetTextColor()
        local background_color = GetBackgroundColor()
        local offset = 9
        for j = 0, image_height - 1 do
            for i = 0, image_width - 1 do
                SetColor(2 ^ tonumber(string.sub(image, offset + 1, offset + 1), 16), 2 ^ tonumber(string.sub(image, offset + 2, offset + 2), 16))
                DrawText(string.sub(image, offset, offset), x + i, y + j)
                offset = offset + 3
            end
        end
        SetColor(text_color, background_color)
    end
end

function _G.DrawImageFromFile(path, x, y, image_width, image_height)
    if type(path) == "string" and fs.exists(path) and not fs.isDir(path) and type(x) == "number" and type(y) == "number" and (type(image_width) == "number" or image_width == nil) and (type(image_height) == "number" or image_height == nil) then
       local file = fs.open(path, "r")
       local image = file.readAll()
       file.close()
       DrawImage(image, x, y, image_width, image_height)
    end
end

function _G.DrawWindowImage(window_id, image, x, y, image_width, image_height)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(image) == "string" and string.sub(image, 0, 4) == BASSIEOS_IMAGE_MAGIC and type(x) == "number" and type(y) == "number" and (type(image_width) == "number" or image_width == nil) and (type(image_height) == "number" or image_height == nil) then
        DrawImage(image, GetWindowX(window_id) + x, GetWindowY(window_id) + y, image_width, image_height)
    end
end

function _G.DrawWindowImageFromFile(window_id, path, x, y, image_width, image_height)
    if type(window_id) == "number" and windows[window_id] ~= nil and type(path) == "string" and fs.exists(path) and not fs.isDir(path) and type(x) == "number" and type(y) == "number" and (type(image_width) == "number" or image_width == nil) and (type(image_height) == "number" or image_height == nil) then
       DrawImageFromFile(path, GetWindowX(window_id) + x, GetWindowY(window_id) + y, image_width, image_height)
    end
end

function _G.Shutdown()
    while #windows_order ~= 0 do
        CloseWindow(windows_order[1])
    end
    running = false
end

RunProgram("/mini/bar.lua")
RunProgram("/mini/wm.lua")