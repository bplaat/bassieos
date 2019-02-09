-- !!BassieOS_INFO!! { type = 11, name = "Paint", version = 2, author = "Bastiaan van der Plaat <bastiaan.v.d.plaat@gmail.com>" }
if BASSIEOS_VERSION == nil then
    print("This program needs BassieOS to run")
    return
end

local menu = { "New", "Open", "Save", "Exit" }

local image = {}
local image_width
local image_height

local current_color = 2 ^ 15

local function PaintEventFunction(window_id, event, param1, param2, param3)
    if event == WINDOW_EVENT_CREATE then
        MaximizeWindow(window_id, true)
    end
    if event == WINDOW_EVENT_CREATE or event == WINDOW_EVENT_SIZE then
        image_width = GetWindowWidth(window_id)
        image_height = GetWindowHeight(window_id) -2
        for i = 1, image_height * image_width do
            image[i] = 1
        end
    end
    if event == WINDOW_EVENT_MOUSE_DOWN or event == WINDOW_EVENT_MOUSE_DRAG then
        local button = param1
        local x = param2
        local y = param3

        if y > 0 and y < GetWindowHeight(window_id) - 1 then
            image[(y - 1) * image_width + x + 1] = current_color
        end
    end
    if event == WINDOW_EVENT_MOUSE_UP then
        local button = param1
        local x = param2
        local y = param3

        CheckWindowMenuClick(window_id, menu, x, y)

        local color_width = math.floor(GetWindowWidth(window_id) / 16)
        for i = 0, 15 do
            if x >= i * color_width and x < (i + 1) * color_width and y == GetWindowHeight(window_id) - 1 then
                current_color = 2 ^ i
                return
            end
        end
    end
    if event == WINDOW_EVENT_MENU then
        if param1 == 3 then
            local file = fs.open("/mini/export.bimg", "w")
            
            file.write(string.format("BIMG%02x%02x", image_width, image_height))
            
            for i = 1, image_height * image_width do
                file.write(string.format(" %1x%1x", math.log(image[i]) / math.log(2), math.log(image[i]) / math.log(2)))
            end
            
            file.close()
        end
        if param1 == 4 then
            CloseWindow(window_id)
        end
    end
    if event == WINDOW_EVENT_PAINT then
        DrawWindowMenu(window_id, menu)

        for y = 0, image_height do
            for x = 0, image_width do
                local color = image[y * image_width + x + 1]
                if color ~= 1 then
                    SetBackgroundColor(color)
                    DrawWindowText(window_id, " ", x, y + 1)
                end
            end
        end

        local color_width = math.floor(GetWindowWidth(window_id) / 16)
        for i = 0, 15 do
            SetTextColor(i == 15 and colors.white or colors.black)
            SetBackgroundColor(2 ^ i)
            DrawWindowText(window_id, string.rep(current_color == 2 ^ i and "#" or " ", color_width), i * color_width, GetWindowHeight(window_id) - 1)
        end
    end
end

CreateWindow("Paint", WINDOW_USE_DEFAULT, WINDOW_USE_DEFAULT, 32, 14, PaintEventFunction)