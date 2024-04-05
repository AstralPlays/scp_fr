scp_fr = scp_fr or {}

local config = {
    [TEAM_SCP049] = {
        ['Job'] = TEAM_SCP049,
        ['BreachPos'] = Vector(0, 0, 0),
        ['Silent'] = true,
        ['Timer'] = (20 * 60),
        ['Adverts'] = {
            [10] = 'SCP-049 Requests a D-Class'
        }
    },
    [TEAM_WENDIGO] = {
        ['Job'] = TEAM_SCP049,
        ['Custom'] = WendigoCheck,
        ['BreachPos'] = Vector(0, 0, 0),
        ['Silent'] = true,
        ['Timer'] = (20 * 60),
        ['Adverts'] = {
            [10] = 'SCP-049 Requests a D-Class'
        }
    }
}

for Job, config in pairs(config) do
    if (config['Custom']) then
        scp_fr.CustomConfig[job] = config
    end    
end

scp_fr.Config = config

function WendigoCheck(config)

end