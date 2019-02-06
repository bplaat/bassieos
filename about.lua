-- !!BassieOS_INFO!! { type = 'BassieOS_APP', name = 'About', version = 1 }

function EventFunction(window_id, event, param1, param2, param3)
    if event == EVENT_PAINT then
        DrawWindowLines(window_id, 'BassieOS is made by the\none and only Bastiaan\nvan der Plaat.' ..
            'For the\nsource code go to\ngithub.com/bplaat/bassieos\n\nVersion: BassieOS version ' .. BASSIEOS_VERSION, 1, 1)
    end
end

if BASSIEOS_VERSION ~= nil then
    CreateWindow('About BassieOS', math.floor((ScreenWidth() - 30) / 2), math.floor((ScreenHeight() - 10 - 1) / 2), 30, 10, EventFunction)
else
    print('This program needs BassieOS to run')
end