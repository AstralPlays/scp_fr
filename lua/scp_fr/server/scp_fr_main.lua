scp_fr = scp_fr or {}
scp_fr.Timers = scp_fr.Timers or {}

if not GAS or not GAS.JobWhitelist then print('SCP_FR: This server does not have BWhitelist installed. SCP_FR Has not been initiated.') return end

function scp_fr.StartTimer(ply)
    if not scp_fr.Timers[ply] then return end
    scp_fr.Timers[ply]['Timer'] = scp_fr.Config[scp_fr.Timers[ply]['Job'].id]['Timer']
    ply:SetNWInt('SCP_FR:Timer', scp_fr.Timers[ply]['Timer'])
    if (ply.scp_fr.LastTimer > 0) then ply.scp_fr.LastTimer = -1 end
end

function scp_fr.StopTimer(ply)
    if not scp_fr.Timers[ply] then return end
    scp_fr.Timers[ply]['Timer'] = -1
    ply:SetNWInt('SCP_FR:Timer', -1)
end

function scp_fr.PauzeTimer(ply)
    if not scp_fr.Timers[ply] then return end
    if (ply.scp_fr.LastTimer == -1) then
        scp_fr.Timers[ply]['Timer'] = ply.scp_fr.LastTimer
        ply.scp_fr.LastTimer = -1
        ply:SetNWInt('SCP_FR:Timer', scp_fr.Timers[ply]['Timer'])
        return
    end
    ply.scp_fr.LastTimer = scp_fr.Timers[ply]['Timer']
    scp_fr.Timers[ply]['Timer'] = -1
    ply:SetNWInt('SCP_FR:Timer', scp_fr.Timers[ply]['Timer'])
end

function scp_fr.AddSCP(ply, job)
    if not GAS.JobWhitelist:IsWhitelisted(ply, job) then continue end
    scp_fr.Timers[ply] = scp_fr.Config[job]
    ply:SetNWInt('SCP_FR:Timer', scp_fr.Timers[ply]['Timer'])
end

function scp_fr.RemoveSCP(ply)
    if not scp_fr.Timers[ply] then return end
    scp_fr.Timers[ply] = nil
    ply:SetNWInt('SCP_FR:Timer', -1)
    ply.scp_fr.LastTimer = -1
end

function scp_fr.Breach(ply)
    ply:SetPos(scp_fr.Timers[ply]['BreachPos'])
    if(scp_fr.Timers[ply]['Silent']) then return end
    scp_fr.net_SendBreach(scp_fr.Timers[ply]['Job']['Name'])
end

function scp_fr.SendAdvert(ply, message)
    local message = '('.. ply ..')'.. message
    scp_fr.net_SendAdvert(scp_fr.Timers[ply]['Job']['Name'])
end

function scp_fr.AskMaintainment(ply)
    if not (scp_fr.Timers[ply]) then return end
    if (scp_fr.Timers[ply]['Timer'] <= 0) then return end

    scp_fr.net_SendMaintainment(ply, scp_fr.Timers[ply]['Job'].id)

    timer.Create('SCP_FR:CheckMaintainment-'.. ply:SteamID64(), 300, 1, function()
        if not (scp_fr.Timers[ply]['Job']) then return end
        if (ply:Team() == scp_fr.Timers[ply]['Job'].id) then return end
        scp_fr.RemoveSCP(ply)
        DarkRP.notify(ply, NOTIFY_GENERIC, 10, 'You have failed to the answer maintainment call. You have been removed from the breach Queue.')
    end)
end

scp_fr.RequestSCPTables = {}
function scp_fr.RequestSCP(ply, job) -- Start asking players with the whitelist to flag on.
    if(scp_fr.RequestSCPTables[job]) then return end
    if not (scp_fr.RequestSCPConfig[ply:Team()]) then return end
    if ply.scp_fr.RequestTimer and (ply.scp_fr.RequestTimer > CurTime()) then return end
    for player, config in pairs(scp_fr.Timers) do
        if (config['Job'].id == job) then return end
    end
    ply.scp_fr.RequestTimer = CurTime() + scp_fr.RequestSCPConfig['Cooldown']
    scp_fr.RequestSCPTables[job] = {}
    local whitelistedPlayers = {}
    for _, ply in ipairs(player.GetAll()) do
        if not GAS.JobWhitelist:IsWhitelisted(ply, job) then continue end
        table.insert(whitelistedPlayers, ply)
    end
    if table.count(whitelistedPlayers) then return end
    scp_fr.RequestSCPTables[job] = whitelistedPlayers
    local firstplayer = table.Random(scp_fr.RequestSCPTables[job])
    scp_fr.RequestSCPTables[job]['CurPlayer'] = firstplayer
    scp_fr.net_SendRequest(ply, job, true)
    timer.Create("SCP_FR:RequestTimer-".. job, 300, 1, function() scp_fr.NextRequest(ply, job) end)
end

function scp_fr.NextRequest(ply, job) -- Ask next player to hop on
    table.RemoveByValue(scp_fr.RequestSCPTables[job], ply)
    if table.Count(scp_fr.RequestSCPTables[job]) == 0 then return end
    local nextplayer = table.Random(scp_fr.RequestSCPTables[job])
    scp_fr.RequestSCPTables[job]['CurPlayer'] = nextplayer
    scp_fr.net_SendRequest(nextplayer, job, true)
    if(timer.Exists("SCP_FR:RequestTimer-".. job)) then timer.Remove("SCP_FR:RequestTimer-".. job) end
end

function scp_fr.StopRequest(job) -- Somebody hopped on the job.
    scp_fr.RequestSCPTables[job] = {}
    scp_fr.net_SendRequest(scp_fr.RequestSCPTables[job]['CurPlayer'], job, true)
end

timer.Create('SCP_FR:Loop', 1, 0, function()
    for team, config in pairs(scp_fr.CustomConfig) do
        scp_fr.CustomConfig['Custom'](config) -- Run custom function
    end
    
    for player, variables in pairs(scp_fr.Timers) do
        if (variables['Timer'] <= 0) then return end
        scp_fr.Timers[player]['Timer'] = (scp_fr.Timers[player]['Timer'] - 1)
        player:SetNWInt('SCP_FR:Timer', scp_fr.Timers[player]['Timer'])

        if(variables['Adverts'][variables['Timer'] * 60]) then scp_fr.SendAdvert(ply, variables['Adverts'][variables['Timer']]) end

        if(variables['Timer'] == 0) then scp_fr.Breach(ply) end
    end
end)

hook.Add('PlayerChangeJob', 'SCP_FR:Jobs', function(ply, oldTeam, newTeam)
    if(scp_fr.Timers[ply]) then
        if not (scp_fr.Timers[ply]['Job'].id == newTeam) then
            scp_fr.RemoveSCP(ply)
            scp_fr.AddSCP(ply)
        elseif (timer.Exists('SCP_FR:CheckMaintainment-'.. ply:SteamID64())) then
            timer.Remove('SCP_FR:CheckMaintainment-'.. ply:SteamID64())
        end
    elseif(scp_fr.Config[newTeam]) then
        scp_fr.AddSCP(ply)
    end
end)

hook.Add('PlayerDisconnected', 'SCP_FR:Jobs', function(ply)
    if(timer.Exists("SCP_FR:RequestTimer-".. ply:Team())) then scp_fr.NextRequest(ply:Team(), job) end
    if(scp_fr.Timers[ply]) then
        scp_fr.RemoveSCP(ply)
    end
end)