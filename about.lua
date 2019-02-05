-- !!BassieOS_INFO!! { type = "BassieOS_APP", name = "About", version = 1 }

function EventFunction(window_id, event, param1, param2, param3)
    if event == EVENT_PAINT then
        DrawWindowText(window_id, "BassieOS is made by the", 1, 1)
        DrawWindowText(window_id, "one and only Bastiaan", 1, 2)
        DrawWindowText(window_id, "van der Plaat. For the", 1, 3)
        DrawWindowText(window_id, "source code go to", 1, 4)
        DrawWindowText(window_id, "github.com/bplaat/bassieos", 1, 5)
        DrawWindowText(window_id, "Version: BassieOS version " .. BASSIEOS_VERSION, 1, 7)
    end
end

if BASSIEOS_VERSION ~= nil then
    CreateWindow("About BassieOS", math.floor((ScreenWidth() - 29) / 2), math.floor((ScreenHeight() - 9 - 1) / 2), 29, 9, EventFunction)
else
    print("This program needs BassieOS to run")
end