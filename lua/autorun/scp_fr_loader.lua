local function IncludeFile(path, isServer)
    if isServer and SERVER then
        print(path)
        include(path)
    elseif not isServer and CLIENT then
        print(path)
        AddCSLuaFile(path)
    end
end

local function LoadServerFiles()
    local files, _ = file.Find('lua/scp_fr/server/*.lua', 'GAME')
    for _, file in ipairs(files) do
        include('lua/scp_fr/server/' .. file, true)
    end
end

local function LoadClientFiles()
    local files, _ = file.Find('lua/scp_fr/client/*.lua', 'GAME')
    for _, file in ipairs(files) do
        include('lua/scp_fr/client/' .. file, false)
    end
end

hook.Add('DarkRPFinishedLoading', 'SCP_FR:LoadConfig', function()
    include('lua/scp_fr/scp_fr_config.lua')
    AddCSLuaFile('lua/scp_fr/scp_fr_config.lua')
    LoadServerFiles()
    LoadClientFiles()
    print('SCP_FR: Loading has been finished.')
    hook.Remove('DarkRPFinishedLoading', 'SCP_FR:LoadConfig')
end)
