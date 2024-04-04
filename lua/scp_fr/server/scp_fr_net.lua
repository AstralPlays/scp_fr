scp_fr = scp_fr or {}

util.AddNetworkString("SCP_FR:Message")
util.AddNetworkString("SCP_FR:Job")
util.AddNetworkString("SCP_FR:Timer")

function scp_fr.net_SendAdvert(message)
    net.Start("SCP_FR:Message")
        net.WriteString("Advert")
        net.WriteString(message)
    net.SendToServer()
end

function scp_fr.net_SendBreach(jobName)
    net.Start("SCP_FR:Message")
        net.WriteString("Breach")
        net.WriteString(jobName)
    net.SendToServer()
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

net.Receive("SCP_FR:Timer", function(len, ply)
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
