windows = {}
windows_id = 1
windows_order = {}
drag_window_id = nil
drag_x = nil

rect = {}
rect["x"] = 1
rect["y"] = 1
rect["width"] = 5
rect["height"] = 3
rect["vx"] = 1
rect["vy"] = 1

term_width, term_height = term.getSize()
background_color = term.getBackgroundColor()
text_color = term.getTextColor()

start_menu = {}
start_menu_opend = false
START_MENU_WIDTH = 13

EVENT_PAINT = 1
EVENT_FOCUS = 2
EVENT_LOST_FOCUS = 3
EVENT_KEY = 4
EVENT_MOUSE_DOWN = 5
EVENT_MOUSE_UP = 6

-- ###############################################

function CreateWindow(title, x, y, width, height, event_function)
    local window = {}
    window["id"] = windows_id
    windows_id = windows_id + 1
    window["title"] = title
    window["x"] = x
    window["y"] = y
    window["width"] = width
    window["height"] = height
    window["minimized"] = false
    window["event_function"] = event_function
    windows[window["id"]] = window
    windows_order[#windows_order + 1] = window["id"]
    FocusWindow(window["id"])
    return window["id"]
end

function FocusWindow(window_id)
    local old_focused_window_id = windows_order[1]
    local new_windows_order = { window_id }
    for i = 1, #windows_order do
        if windows_order[i] ~= window_id then
            new_windows_order[#new_windows_order + 1] = windows_order[i]
        end
    end
    windows_order = new_windows_order
    if old_focused_window_id ~= nil then
        windows[old_focused_window_id]["event_function"](windows[old_focused_window_id], EVENT_LOST_FOCUS)
    end
    windows[window_id]["event_function"](windows[window_id], EVENT_FOCUS)
end

function MinimizeWindow(window_id)
    windows[window_id]["minimized"] = true
    local is_focused = window_id == windows_order[1]
    local new_windows_order = {}
    for i = 1, #windows_order do
        if windows_order[i] ~= window_id then
            new_windows_order[#new_windows_order + 1] = windows_order[i]
        end
    end
    new_windows_order[#new_windows_order + 1] = window_id
    windows_order = new_windows_order
    if is_focused then
        windows[window_id]["event_function"](windows[window_id], EVENT_LOST_FOCUS)
    end
    if #windows_order > 1 then
        windows[windows_order[1]]["event_function"](windows[windows_order[1]], EVENT_FOCUS)
    end
end

function ShowWindow(window_id)
    windows[window_id]["minimized"] = false
    FocusWindow(window_id)
end

function MoveWindow(window_id, x, y)
    windows[window_id]["x"] = x
    windows[window_id]["y"] = y
end

function CloseWindow(window_id)
    windows[window_id] = 0
    local new_windows_order = {}
    for i = 1, #windows_order do
        if windows_order[i] ~= window_id then
            new_windows_order[#new_windows_order + 1] = windows_order[i]
        end
    end
    windows_order = new_windows_order
    if #windows_order ~= 0 then
        windows[windows_order[1]]["event_function"](windows[windows_order[1]], EVENT_FOCUS)
    end
end

-- ###############################################

function OpenCalculator()
    local x = 1
    local vx = 1
    local buffer = ""
    function CalculatorEventFunction(window, event, param1)
        if event == EVENT_KEY then
            buffer = buffer .. keys.getName(param1)
        end
        if event == EVENT_PAINT then
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.red)
            term.setCursorPos(window["x"] + x, window["y"])
            term.write("2 + 3 = 5")
            
            term.setCursorPos(window["x"], window["y"] + 1)
            term.write(buffer)
            
            if x <= 0 then
                vx = 1
            end
            if x + 9 > window["width"] then
                vx = -1
            end
            
            x = x + vx
        end
    end
    CreateWindow("Calculator", 4, 4, 20, 10, CalculatorEventFunction)
end

function OpenTaskManager()
    function TaskManagerEventFunction(window, event)
        if event == EVENT_PAINT then
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.purple)
            local offset = 0
            for i = 1, #windows_order do
                local window_item = windows[windows_order[i]]
                term.setCursorPos(window["x"], window["y"] + offset)
                if window_item["minimized"] == true then
                     term.write("#" .. windows_order[i] .. " - " .. window_item["title"] .. " - " ..
                        window_item["x"] .. "x" .. window_item["y"] .. " " ..
                        window_item["width"] .. "x" .. window_item["height"] .. " min")
                else
                    term.write("#" .. windows_order[i] .. " - " .. window_item["title"] .. " - " ..
                        window_item["x"] .. "x" .. window_item["y"] .. " " ..
                        window_item["width"] .. "x" .. window_item["height"])
                end
                offset = offset + 1
            end
        end
    end
    CreateWindow("Task Manager", 6, 6, 40, 10, TaskManagerEventFunction)
end

function OpenAbout()
    local button = 0
    local x = 0
    local y = 0
    local q = false
    local focused = false
    function AboutEventFunction(window, event, param1, param2, param3)
        if event == EVENT_FOCUS then
            focused = true
        end
        if event == EVENT_LOST_FOCUS then
            focused = false
        end
        if event == EVENT_MOUSE_DOWN then
            button = param1
            x = param2
            y = param3
            q = true
        end
        if event == EVENT_MOUSE_UP then
            x = param2
            y = param3
            q = false
        end
        if event == EVENT_PAINT then
            term.setTextColor(colors.white)
            term.setBackgroundColor(focused and colors.blue or colors.red)
            term.setCursorPos(window["x"], window["y"])
            term.write("This is made by")
            term.setCursorPos(window["x"], window["y"] + 1)
            term.write("Bastiaan van")
            term.setCursorPos(window["x"], window["y"] + 2)
            term.write("der Plaat have")
            term.setCursorPos(window["x"], window["y"] + 3)
            term.write("fun and enjoy!")
            term.setBackgroundColor(q and colors.green or colors.lime)
            term.setCursorPos(window["x"], window["y"] + 5)
            term.write(button .. " " .. x .. "x" .. y)
        end
    end
    CreateWindow("About BassieOS more", 28, 2, 20, 10, AboutEventFunction)
end

OpenCalculator()
OpenTaskManager()
OpenAbout()

start_menu = {
    "Calculator", OpenCalculator,
    "Task Manager", OpenTaskManager,
    "About", OpenAbout,
    "Shutdown", os.shutdown
}

-- ###############################################

os.startTimer(1/20)

function HandleMouseDown(button, x, y)
    if start_menu_opend == true then
        if (y >= term_height - (#start_menu / 2) and x <= START_MENU_WIDTH and y <= term_height - 1) or (x <= 5 and y == term_height) then
            return
        else
            start_menu_opend = false
        end
    end

    for i = 1, #windows_order do
        local window = windows[windows_order[i]]
        if window["minimized"] == false then
            if x >= window["x"] - 1 and y >= window["y"] - 1 and
                x <= window["x"] + window["width"] + 1 and
                y <= window["y"] + window["height"] + 1 then
                if windows_order[1] ~= window["id"] then
                    FocusWindow(window["id"])
                end
                if x >= window["x"] and y == window["y"] - 1 and
                    x <= window["x"] + window["width"] - 2 then
                    drag_window_id = window["id"]
                    drag_x = x - window["x"]
                end
                if x >= window["x"] and y >= window["y"] and
                    x < window["x"] + window["width"] and y < window["y"] + window["height"] then
                    window["event_function"](window, EVENT_MOUSE_DOWN, button, x - window["x"], y - window["y"])
                end
                return
            end
        end
    end
end

function HandleMouseUp(button, x, y)
    drag_window_id = nil
    
    if start_menu_opend == true then
        for i = 1, #start_menu, 2 do
            if x >= 1 and y == (term_height - (#start_menu / 2) + (i - 1) / 2) and x <= START_MENU_WIDTH then
                start_menu[i + 1]()
                start_menu_opend = false
                return
            end
        end
    elseif x >= 1 and y == term_height and x <= 5 then
        start_menu_opend = true
        return
    end

    for i = 1, #windows_order do
        local window = windows[windows_order[i]]
        if window["minimized"] == false then
            if x == window["x"] + window["width"] - 1 and y == window["y"] - 1  then
                MinimizeWindow(window["id"])
                return
            end
            if x == window["x"] + window["width"] and y == window["y"] - 1  then
                CloseWindow(window["id"])
                return
            end
            if x >= window["x"] and y >= window["y"] and
                x < window["x"] + window["width"] and y < window["y"] + window["height"] then
                window["event_function"](window, EVENT_MOUSE_UP, button, x - window["x"], y - window["y"])
                return
            end
        end
    end

    local offset = 7
    for i = 1, #windows do
        if windows[i] ~= 0 then
            if x >= offset and y == term_height and x <= offset + 4 then
                if windows[i]["minimized"] == true then
                    ShowWindow(i)
                elseif i == windows_order[1] then
                    MinimizeWindow(i)
                else
                    FocusWindow(i)
                end
                return
            end
            offset = offset + 6
        end
    end
end

while true do
    local event, param1, param2, param3 = os.pullEvent()

    if event == "timer" then
        term.setBackgroundColor(colors.cyan)
        term.clear()

        -- System info
        term.setTextColor(colors.white)
        term.setCursorPos(1, 1)
        term.write("BassieOS v19.2.4 at #" .. os.getComputerID())

        -- Dancing rect
        term.setBackgroundColor(colors.magenta)
        for y = 0, rect["height"] do
            term.setCursorPos(rect["x"], rect["y"] + y)
            term.write(string.rep(" ", rect["width"] + 1))
        end

        if rect["x"] <= 0 then
            rect["vx"] = rect["vx"] * -1
        end
        if rect["y"] <= 0 then
            rect["vy"] = rect["vy"] * -1
        end
        if rect["x"] + rect["width"] > term_width then
            rect["vx"] = rect["vx"] * -1
        end
        if rect["y"] + rect["height"] > term_height - 1 then
            rect["vy"] = rect["vy"] * -1
        end

        rect["x"] = rect["x"] + rect["vx"]
        rect["y"] = rect["y"] + rect["vy"]

        -- Drawing windows
        for i = #windows_order, 1, -1 do
            local window = windows[windows_order[i]]
            if window["minimized"] == false then
                term.setBackgroundColor(i == 1 and colors.black or colors.gray)
                for y = -1, window["height"] + 1 do
                    term.setCursorPos(window["x"] - 1, window["y"] + y)
                    term.write(string.rep(" ", window["width"] + 3))
                end

                term.setBackgroundColor(colors.white)
                for y = 0, window["height"] do
                    term.setCursorPos(window["x"], window["y"] + y)
                    term.write(string.rep(" ", window["width"] + 1))
                end

                term.setCursorPos(window["x"], window["y"] - 1)
                term.setTextColor(colors.white)
                term.setBackgroundColor(i == 1 and colors.black or colors.gray)
                term.write(string.sub(window["title"], 0, window["width"] - 2))

                term.setCursorPos(window["x"] + window["width"] - 1, window["y"] - 1)
                term.setBackgroundColor(colors.orange)
                term.write("_")
                term.setBackgroundColor(colors.red)
                term.write("X")

                window["event_function"](window, EVENT_PAINT)
            end
        end

        -- Start bar
        term.setCursorPos(1, term_height)
        term.setBackgroundColor(colors.lime)
        term.write(string.rep(" ", term_width))

        term.setCursorPos(1, term_height)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write("Start")

        local focused_window_id = windows_order[1]
        for i = 1, #windows do
            if windows[i] ~= 0 then
                term.setBackgroundColor(colors.lime)
                term.write(" ")
                term.setBackgroundColor(windows[i]["minimized"] == true and colors.yellow or (i == focused_window_id and colors.green or colors.orange))
                term.write(string.sub(windows[i]["title"], 0, 5))
            end
        end

        local time_label = textutils.formatTime(os.time(), true)
        if string.len(time_label) == 4 then
            time_label = "0" .. time_label
        end
        term.setCursorPos(term_width - string.len(time_label) + 1, term_height)
        term.setBackgroundColor(colors.green)
        term.write(time_label)

        if start_menu_opend == true then
            for i = 1, #start_menu, 2 do
                term.setCursorPos(1, term_height - (#start_menu / 2) + (i - 1) / 2)
                term.setBackgroundColor(colors.lime)
                term.write(string.sub(start_menu[i], 0, START_MENU_WIDTH) .. string.rep(" ", START_MENU_WIDTH - string.len(start_menu[i])))
            end
        end

        os.startTimer(1 / 20)
    end

    if event == "mouse_click" then
        HandleMouseDown(param1, param2, param3)
    end

    if event == "mouse_up" then
        HandleMouseUp(param1, param2, param3)
    end

    if event == "mouse_drag" then
        if drag_window_id ~= nil then
            MoveWindow(drag_window_id, param2 - drag_x, param3 + 1)
        end
    end

    if event == "key" and #windows_order > 0 and windows[windows_order[1]]["minimized"] == false then
        windows[windows_order[1]]["event_function"](windows[windows_order[1]], EVENT_KEY, param1)
    end
end