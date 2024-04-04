include("lua/scp_fr/scp_fr_config.lua")
AddCSLuaFile("lua/scp_fr/scp_fr_config.lua")

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
    local files, _ = file.Find("lua/scp_fr/server/*.lua", "GAME")
    for _, file in ipairs(files) do
        IncludeFile("d_rep/server/" .. file, true)
    end
end

local function LoadClientFiles()
    local files, _ = file.Find("lua/scp_fr/client/*.lua", "GAME")
    for _, file in ipairs(files) do
        IncludeFile("d_rep/client/" .. file, false)
    end
end
LoadServerFiles()
LoadClientFiles()