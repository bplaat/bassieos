-- !!BassieOS_INFO!! { type = 11, name = "About", version = 2, icon = "BIMG0403SfaYfaSfa aaIf1Nf1Ff1Of1WfeIfeNfe ee", author = "Bastiaan van der Plaat <bastiaan.v.d.plaat@gmail.com>" }
if BASSIEOS_VERSION == nil then
    print("This program needs BassieOS to run")
    return
end

local function AboutEventFunction(window_id, event, param1, param2, param3)
    if event == WINDOW_EVENT_PAINT then
        DrawWindowText(window_id, "BassieOS is made by the", 1, 1)
        DrawWindowText(window_id, "one and only Bastiaan", 1, 2)
        DrawWindowText(window_id, "van der Plaat. For the", 1, 3)
        DrawWindowText(window_id, "source code go to", 1, 4)
        DrawWindowText(window_id, "github.com/bplaat/bassieos", 1, 5)
        DrawWindowText(window_id, "Version: BassieOS version " .. BASSIEOS_VERSION, 1, 7)
    end
end

CreateWindow("About BassieOS", WINDOW_USE_DEFAULT, WINDOW_USE_DEFAULT, 30, 10, AboutEventFunction)