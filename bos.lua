windows = {}
windows_id = 1
windows_order = {}
drag_window_id = nil
drag_x = nil

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
    windows[old_focused_window_id]["event_function"](windows[old_focused_window_id], "lost_focus")
    windows[window_id]["event_function"](windows[window_id], "focus")
end

function MinimizeWindow(window_id)
    windows[window_id]["minimized"] = true
    local new_windows_order = {}
    for i = 1, #windows_order do
        if windows_order[i] ~= window_id then
            new_windows_order[#new_windows_order + 1] = windows_order[i]
        end
    end
    new_windows_order[#new_windows_order + 1] = window_id
    windows_order = new_windows_order
    windows[window_id]["event_function"](windows[window_id], "lost_focus")
    windows[windows_order[1]]["event_function"](windows[windows_order[1]], "focus")
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
    windows[window_id] = nil
    local new_windows_order = {}
    for i = 1, #windows_order do
        if windows_order[i] ~= window_id then
            new_windows_order[#new_windows_order + 1] = windows_order[i]
        end
    end
    windows_order = new_windows_order
    if #windows_order ~= 0 then
        windows[windows_order[1]]["event_function"](windows[windows_order[1]], "focus")
    end
end

-- ###############################################

function OpenCalculator()
    local x = 1
    local vx = 1
    function CalculatorEventFunction(window, event)
        if event == "paint" then
            term.setTextColor(colors.black)
            term.setBackgroundColor(colors.red)
            term.setCursorPos(window["x"] + x, window["y"])
            term.write("2 + 3 = 5")
            
            if x <= 0 then
                vx = 1;
            end
            if x + 9 > window["width"] then
                vx = -1;
            end
            
            x = x + vx
        end
    end
    CreateWindow("Calculator", 4, 4, 20, 10, CalculatorEventFunction)
end

function OpenAbout()
    local focused = false
    function AboutEventFunction(window, event)
        if event == "focus" then
            focused = true
        end
        if event == "lost_focus" then
            focused = false
        end

        if event == "paint" then
            term.setTextColor(colors.white)
            if focused then
                term.setBackgroundColor(colors.blue)
            else
                term.setBackgroundColor(colors.red)
            end
            term.setCursorPos(window["x"], window["y"])
            term.write("This is made")
            term.setCursorPos(window["x"], window["y"] + 1)
            term.write("by Bastiaan")
            term.setCursorPos(window["x"], window["y"] + 2)
            term.write("van der Plaat")
        end
    end
    CreateWindow("About BassieOS", 22, 8, 15, 8, AboutEventFunction)
end

function OpenTaskManager()
    function TaskManagerEventFunction(window, event)
        if event == "paint" then
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
    CreateWindow("Task Manager", 15, 3, 34, 10, TaskManagerEventFunction)
end

OpenCalculator()
OpenAbout()
OpenTaskManager()

-- ###############################################

term_width, term_height = term.getSize()

rect = {}
rect["x"] = 1
rect["y"] = 1
rect["width"] = 5
rect["height"] = 3
rect["vx"] = 1
rect["vy"] = 1

term.setCursorBlink(false)
background_color = term.getBackgroundColor()
text_color = term.getTextColor()

os.startTimer(1/20)

while true do
    local event, param1, param2, param3 = os.pullEvent()

    if event == "timer" then
        term.setBackgroundColor(colors.cyan)
        term.clear()

        -- System info
        term.setTextColor(colors.black)
        term.setCursorPos(1, 1)
        term.write("BassieOS v19.2.4 at #" .. os.getComputerID())

        -- Dancing rect
        term.setBackgroundColor(colors.magenta)
        for y = 0, rect["height"] do
            for x = 0, rect["width"] do
                term.setCursorPos(rect["x"] + x, rect["y"] + y)
                term.write(" ")
            end
        end

        if rect["x"] <= 0 then
            rect["vx"] = rect["vx"] * -1;
        end
        if rect["y"] <= 0 then
            rect["vy"] = rect["vy"] * -1;
        end
        if rect["x"] + rect["width"] > term_width then
            rect["vx"] = rect["vx"] * -1;
        end
        if rect["y"] + rect["height"] > term_height - 1 then
            rect["vy"] = rect["vy"] * -1;
        end

        rect["x"] = rect["x"] + rect["vx"]
        rect["y"] = rect["y"] + rect["vy"]

        -- Drawing windows
        for i = #windows_order, 1, -1 do
            local window = windows[windows_order[i]]
            if window["minimized"] == false then
                if i == 1 then
                    term.setBackgroundColor(colors.black)
                else 
                    term.setBackgroundColor(colors.gray)
                end
                for y = -1, window["height"] + 1 do
                    for x = -1, window["width"] + 1 do
                        term.setCursorPos(window["x"] + x, window["y"] + y)
                        term.write(" ")
                    end
                end

                term.setBackgroundColor(colors.white)
                for y = 0, window["height"] do
                    for x = 0, window["width"] do
                        term.setCursorPos(window["x"] + x, window["y"] + y)
                        term.write(" ")
                    end
                end

                term.setCursorPos(window["x"], window["y"] - 1)
                term.setTextColor(colors.white)
                if i == 1 then
                    term.setBackgroundColor(colors.black)
                else 
                    term.setBackgroundColor(colors.gray)
                end
                term.write(window["title"])

                term.setCursorPos(window["x"] + window["width"] - 1, window["y"] - 1)
                term.setBackgroundColor(colors.orange)
                term.write("_")

                term.setCursorPos(window["x"] + window["width"], window["y"] - 1)
                term.setBackgroundColor(colors.red)
                term.write("X")

                window["event_function"](window, "paint")
            end
        end

        -- Start bar
        term.setBackgroundColor(colors.lime)
        for x = 1, term_width do
            term.setCursorPos(x, term_height)
            term.write(" ")
        end

        term.setCursorPos(1, term_height)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write("Start")

        local offset = 7

        for i = 1, #windows_order do
            local window = windows[windows_order[i]]
            term.setCursorPos(offset, term_height)
            term.setTextColor(colors.white)
            if i == 1 then
                term.setBackgroundColor(colors.green)
            elseif window["minimized"] == true then
                term.setBackgroundColor(colors.yellow)
            else
                term.setBackgroundColor(colors.orange)
            end
            term.write(string.sub(window["title"], 0, 5))
            offset = offset + 6
        end

        local time_label = textutils.formatTime(os.time(), true)

        if string.len(time_label) == 4 then
            time_label = "0" .. time_label
        end

        term.setCursorPos(term_width - string.len(time_label) + 1, term_height)
        term.setBackgroundColor(colors.green)
        term.write(time_label)

        os.startTimer(1 / 20)
    end

    if event == "mouse_click" then
        local x = param2
        local y = param3

        if x == 1 and y == term_height then
            OpenCalculator()
        end
        if x == 2 and y == term_height then
            OpenAbout()
        end
        if x == 3 and y == term_height then
            OpenTaskManager()
        end
        
        local offset = 7
        for i = 1, #windows_order do
            if x >= offset and y == term_height and x < offset + 5 then
                local window = windows[windows_order[i]]
                if window["minimized"] == true then
                    ShowWindow(window["id"])
                elseif i ~= 1 then
                    FocusWindow(window["id"])
                end
                break
            end
            offset = offset + 6
        end

        for i = 1, #windows_order do
            local window = windows[windows_order[i]]
            if window["minimized"] == false then
                if x >= window["x"] - 1 and y >= window["y"] - 1 and
                    x <= window["x"] + window["width"] + 1 and
                    y <= window["y"] + window["height"] + 1 then
                    
                    if x >= window["x"] and y == window["y"] - 1 and
                        x <= window["x"] + window["width"] - 2 then
                        drag_window_id = window["id"]
                        drag_x = x - window["x"]
                    end
                    
                    if x == window["x"] + window["width"] - 1 and y == window["y"] - 1  then
                        MinimizeWindow(window["id"])
                    elseif x == window["x"] + window["width"] and y == window["y"] - 1  then
                        CloseWindow(window["id"])
                    elseif windows_order[1] ~= window["id"] then
                        FocusWindow(window["id"])
                    end
                    
                    break
                end
            end
        end
    end

    if event == "mouse_drag" then
        local x = param2
        local y = param3

        if drag_window_id ~= nil then
            MoveWindow(drag_window_id, x - drag_x, y + 1)
        end
    end
    
    if event == "mouse_up" then
        drag_window_id = nil
    end

    if event == "key" then
        local key = param1
        if key == keys.backspace then
            break
        end
    end
end

term.setCursorBlink(true)
term.setBackgroundColor(background_color)
term.setTextColor(text_color)
term.clear()
term.setCursorPos(1, 1)
