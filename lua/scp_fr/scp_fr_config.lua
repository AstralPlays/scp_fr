scp_fr = scp_fr or {}

local config = {
    [TEAM_SCP049] = {
        ['Job'] = TEAM_SCP049,
        ['Custom'] = false,
        ['BreachPos'] = Vector(0, 0, 0),
        ['Silent'] = true,
        ['Timer'] = (20 * 60),
        ['Adverts'] = {
            [10] = 'SCP-049 Requests a D-Class'
        }
    }
}

scp_fr.Config = config