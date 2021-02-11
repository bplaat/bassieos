-- BassieOS_Info { type = 11, name = 'Theme', description = 'Switch the theme of BassieOS', versionNumber = 30, versionString = '3.0', icon = 'BIMG0403D0fKffKffK00LffKffK00L00KffK00K00Lf0', author = 'Bastiaan van der Plaat' }
if BassieOS == nil then
    print('This program needs BassieOS to run')
    return
end

BassieOS.CreateMessage('Theme Switcher', 'Your system theme switched\nbetween light and dark...')

BassieOS.SetTheme(BassieOS.GetTheme() == BassieOS.Theme.LIGHT and BassieOS.Theme.DARK or BassieOS.Theme.LIGHT)
