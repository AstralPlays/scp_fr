scp_fr = scp_fr or {}

if not GAS or not GAS.JobWhitelist then print('SCP_FR: This server does not have BWhitelist installed. SCP_FR Has not been initiated.') return end

util.AddNetworkString('SCP_FR:Message')
util.AddNetworkString('SCP_FR:Timer')

function scp_fr.net_SendRequest(ply, job)
    net.Start('SCP_FR:Message')
        net.WriteString('Request')
        net.WriteInt(job, 32)
    net.Send(ply)
end

function scp_fr.net_SendMaintainment(ply, job)
    net.Start('SCP_FR:Message')
        net.WriteString('Message')
        net.WriteInt(job, 32)
    net.Send(ply)
end

function scp_fr.net_SendAdvert(message)
    net.Start('SCP_FR:Message')
        net.WriteString('Advert')
        net.WriteString(message)
    net.Broadcast()
end

function scp_fr.net_SendBreach(jobName)
    net.Start('SCP_FR:Message')
        net.WriteString('Breach')
        net.WriteString(jobName)
    net.Broadcast()
end

local function checkJob(ply, job)
    if(scp_fr.Timers[ply]) then
        scp_fr.RemoveSCP(ply)
        if (scp_fr.Timers[ply]['Job'].id == job) then return end
        scp_fr.AddSCP(ply, job)
        return
    end
    scp_fr.AddSCP(ply, job)
end

net.Receive('SCP_FR:Timer', function(len, ply)
    local method = net.ReadString()
    if (method == 'Job') then
        local job = net.ReadInt(32)
        checkJob(ply, job)
    elseif (method == 'TimerStart') then
        scp_fr.StartTimer(ply)
    elseif (method == 'TimerStop') then
        scp_fr.StopTimer(ply)
    end
end)

net.Receive('SCP_FR:Message', function(len, ply)
    local method = net.ReadString()
    if (method == 'RespondRequest') then
        local job = net.ReadInt(32)
        local response = net.ReadBool()
        if not scp_fr.RequestSCPTables[job][ply] then return end
        if response then
            local jobCommand = RPExtraTeams[jobid].command
            ply:Say('/'.. jobCommand)
        else
            scp_fr.NextRequest(ply, job)
        end
    elseif (method == 'RequestSCP') then
        local job = net.ReadInt(32)
        scp_fr.RequestSCP(ply, job)
    end
end)