-- BassieOS_Info { type = 11, name = 'Stop', description = 'Stop BassieOS', versionNumber = 30, versionString = '3.0', icon = 'BIMG0403 0e-0e-0e 0eS0eT0eO0eP0e 0e-0e-0e 0e', author = 'Bastiaan van der Plaat' }
if BassieOS == nil then
    print('This program needs BassieOS to run')
    return
end

BassieOS.StopRunning()
