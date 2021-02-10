-- BassieOS_Info { type = 11, name = 'Settings', description = 'The settings for BassieOS', versionNumber = 30, versionString = '3.0', author = 'Bastiaan van der Plaat' }
if BassieOS == nil then
    print('This program needs BassieOS to run')
    return
end

BassieOS.CreateMessage('Settings', 'Your system theme switched\nbetween light and dark...')

BassieOS.SetTheme(BassieOS.GetTheme() == BassieOS.Theme.LIGHT and BassieOS.Theme.DARK or BassieOS.Theme.LIGHT)
