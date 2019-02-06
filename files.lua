-- !!BassieOS_INFO!! { type = 'BassieOS_APP', name = 'Files', version = 1 }

local menu
local paths = { '/' }
local path
local files_list

local function LoadFolder(window_id)
    path = ''
    for i = 1, #paths do
        path = path .. paths[i]
    end
    SetWindowTitle(window_id, 'Files - ' .. path)

    menu = { 'Up' }
    for i = 1, #paths do
        menu[#menu + 1] = paths[i]
    end

    local files = fs.list(path)
    files_list = {}
    for i = 1, #files do
        if fs.isDir(path .. files[i]) then
            files_list[#files_list + 1] = files[i] .. '/'
            files_list[#files_list + 1] = #fs.list(path .. files[i])
            
        end
    end
    for i = 1, #files do
        if not fs.isDir(path .. files[i]) then
            files_list[#files_list + 1] = files[i]
            files_list[#files_list + 1] = fs.getSize(path .. files[i])
        end
    end
end

function EventFunction(window_id, event, param1, param2, param3)
    if event == EVENT_CREATE then
        LoadFolder(window_id)
    end
    if event == EVENT_MENU then
        local menu_item = param1

        if menu_item == 1 then
            if #paths > 1 then
                paths[#paths] = nil
                LoadFolder(window_id)
                return
            end
        end

        for i = 1, #paths do
            if menu_item == i + 1 then
                for j = menu_item, #paths do
                    paths[j] = nil
                end
                LoadFolder(window_id)
                return
            end
        end
    end
    if event == EVENT_MOUSE_UP then
        local x = param2
        local y = param3

        CheckWindowMenuClick(window_id, menu, x, y)

        for i = 1, #files_list, 2 do
            if x >= 0 and x < GetWindowWidth(window_id) and y == math.ceil(i / 2) then
                if string.sub(files_list[i], string.len(files_list[i])) == '/' then
                    paths[#paths + 1] = files_list[i]
                    LoadFolder(window_id)
                else
                    local info = GetProgramInfo(path .. files_list[i])
                    if info ~= nil and info.type == 'BassieOS_APP' then
                        RunProgram(path .. files_list[i])
                    else
                        RunProgram('edit.lua', { ['path'] = path .. files_list[i] })
                    end
                end
                return
            end
        end
    end
    if event == EVENT_PAINT then
        DrawWindowMenu(window_id, menu)
        for i = 1, math.min(#files_list, (GetWindowHeight(window_id) - 1) * 2), 2 do
            if string.sub(files_list[i], string.len(files_list[i])) == '/' then
                term.setBackgroundColor(colors.yellow)
                local text = files_list[i] .. ' - ' ..  files_list[i + 1] .. ' files'
                DrawWindowText(window_id, text .. string.rep(' ', GetWindowWidth(window_id) - string.len(text)), 0, math.ceil(i / 2))
            else
                term.setBackgroundColor(colors.white)
                DrawWindowText(window_id, files_list[i] .. ' - ' ..  math.ceil(files_list[i + 1] / 1024) .. ' KB', 0, math.ceil(i / 2))
            end
        end
    end
end

if BASSIEOS_VERSION ~= nil then
    CreateWindow('Files', math.floor((ScreenWidth() - 30) / 2), math.floor((ScreenHeight() - 14 - 1) / 2), 30, 14, EventFunction)
else
    print('This program needs BassieOS to run')
end