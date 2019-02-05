-- !!BassieOS_INFO!! { type = "BassieOS_APP", name = "Paint", version = 1 }

local data = {}

function EventFunction(window_id, event, param1, param2, param3)
    if event == EVENT_CREATE or event == EVENT_RESIZE then
        for i = 1, GetWindowHeight(window_id) * GetWindowWidth(window_id) do
            data[i] = 0
        end
    end
    if event == EVENT_MOUSE_DOWN or event == EVENT_MOUSE_DRAG then
        if param1 == 1 then
            data[param3 * GetWindowWidth(window_id) + param2 + 1] = 1
        end
        if param1 == 2 then
            data[param3 * GetWindowWidth(window_id) + param2 + 1] = 0
        end
    end
    if event == EVENT_PAINT then
        for y = 0, GetWindowHeight(window_id) do
            for x = 0, GetWindowWidth(window_id) do
                if data[y * GetWindowWidth(window_id) + x + 1] == 1 then
                    term.setBackgroundColor(colors.black)
                    DrawWindowText(window_id, " ", x, y)
                end
            end
        end
    end
end

if BASSIEOS_VERSION ~= nil then
    local window_id = CreateWindow("Paint", math.floor((ScreenWidth() - 32) / 2), math.floor((ScreenHeight() - 14 - 1) / 2), 32, 14, EventFunction)
    MaximizeWindow(window_id)
else
    print("This program needs BassieOS to run")
end