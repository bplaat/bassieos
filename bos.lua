term_width, term_height = term.getSize()

rect = {}
rect["x"] = 1
rect["y"] = 1
rect["width"] = 5
rect["height"] = 3
rect["vx"] = 1
rect["vy"] = 1

windows = {}

function CreateWindow(title, x, y, width, height, event_function)
    window = {}
    window["id"] = #windows + 1
    window["title"] = title
    window["x"] = x
    window["y"] = y
    window["width"] = width
    window["height"] = height
    window["event_function"] = event_function
    windows[window["id"]] = window
    return window["id"]
end

x = 1
vx = 1
function CalculatorEventFunction(window, event)
    if event == "paint" then
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.red)
        term.setCursorPos(window["x"] + x, window["y"])
        term.write("2 + 3 = 5")
        
        if x <= 0 then
            vx = vx * -1;
        end
        if x + 9 > window["width"] then
            vx = vx * -1;
        end
        
        x = x + vx
    end
end
win1 = CreateWindow("Calculator", 4, 4, 20, 10, CalculatorEventFunction)

function AboutEventFunction(window, event)
    if event == "paint" then
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.white)
        term.setCursorPos(window["x"], window["y"])
        term.write("This is made")
        term.setCursorPos(window["x"], window["y"] + 1)
        term.write("by Bastiaan")
        term.setCursorPos(window["x"], window["y"] + 2)
        term.write("van der Plaat")
    end
end
win2 = CreateWindow("About BassieOS", 30, 5, 15, 8, AboutEventFunction)

term.setCursorBlink(false)
background_color = term.getBackgroundColor()
text_color = term.getTextColor()

os.startTimer(1/20)

while true do
    event, param = os.pullEvent()

    if event == "timer" then
        term.setBackgroundColor(colors.cyan)
        term.clear()

        -- System info
        term.setCursorPos(1, 1)
        term.setTextColor(colors.black)
        term.write("BassieOS v19.2.3 at #" .. os.getComputerID())

        -- Dancing rect
        for y = 0, rect["height"] do
            for x = 0, rect["width"] do
                term.setCursorPos(rect["x"] + x, rect["y"] + y)
                term.blit(" ", "a", "a")
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
        for _,window in ipairs(windows) do
            for y = -1, window["height"] + 1 do
                for x = -1, window["width"] + 1 do
                    term.setCursorPos(window["x"] + x, window["y"] + y)
                    term.blit(" ", "f", "f")
                end
            end

            for y = 0, window["height"] do
                for x = 0, window["width"] do
                    term.setCursorPos(window["x"] + x, window["y"] + y)
                    term.blit(" ", "0", "0")
                end
            end

            term.setCursorPos(window["x"], window["y"] - 1)
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.gray)
            term.write(window["title"])

            term.setCursorPos(window["x"] + window["width"], window["y"] - 1)
            term.blit("X", "0", "e")

            window["event_function"](window, "paint")
        end

        -- Start bar
        for x = 1, term_width do
            term.setCursorPos(x, term_height)
            term.blit(" ", "5", "5")
        end

        term.setCursorPos(1, term_height)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write("Start")

        time_label = textutils.formatTime(os.time(), true)

        if string.len(time_label) == 4 then
            time_label = "0" .. time_label
        end

        term.setCursorPos(term_width - string.len(time_label) + 1, term_height)
        term.write(time_label)

        os.startTimer(1/20)
    end

    if event == "key" and param == keys.backspace then
        break
    end
end

term.setCursorBlink(true)
term.setBackgroundColor(background_color)
term.setTextColor(text_color)
term.clear()
term.setCursorPos(1, 1)
