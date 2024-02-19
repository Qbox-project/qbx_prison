Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use ox_target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.moneyReceived = 80

Config.Jobs = {
    electrician = {
        locations = {
            vec3(1761.46, 2540.41, 45.56),
            vec3(1718.54, 2527.802, 45.56),
            vec3(1700.199, 2474.811, 45.56),
            vec3(1664.827, 2501.58, 45.56),
            vec3(1621.622, 2509.302, 45.56),
            vec3(1627.936, 2538.393, 45.56),
            vec3(1625.1, 2575.988, 45.56),
        },
        reward = 'phone',
        rewardChance = 1, -- out of 100
        canOnlyGetOneReward = true, -- if true, once reward is found, will not get another
    }
}

Config.Uniforms ={
    male = {
        outfitData ={
            ['t-shirt'] = {item = 15, texture = 0},
            ['torso2'] = {item = 345, texture = 0},
			['arms'] = {item = 19, texture = 0},
			['pants'] = {item = 3, texture = 7},
			['shoes'] = {item = 1, texture = 0},
        }
    },
    female = {
        outfitData ={
            ['t-shirt'] = {item = 14, texture = 0},
			['torso2'] = {item = 370, texture = 0},
			['arms'] = {item = 0, texture = 0},
			['pants'] = {item = 0, texture = 12},
			['shoes'] = {item = 1, texture = 0},
        }
    },
}

Config.Locations = {
    prison = {
        {label = 'Prison', coords = vec3(1678.9, 2513.4, 45.6)},
    },
    freedom = {
        coords = vector4(1740.88, 2476.57, 44.85, 299.49)
    },
    outside = {
        coords = vector4(1848.13, 2586.05, 44.67, 269.5)
    },
    yard = {
        coords = vector4(1765.67, 2565.91, 44.56, 1.5)
    },
    middle = {
        coords = vec3(1693.33, 2569.51, 44.55)
    },
    shop = {
        coords = vector4(1777.59, 2560.52, 44.62, 187.83)
    },
    spawns = {
        {
            animation = "bumsleep",
            coords = vector4(1661.046, 2524.681, 45.564, 260.545)
        },
        {
            animation = "lean",
            coords = vector4(1650.812, 2540.582, 45.564, 230.436)
        },
        {
            animation = "lean",
            coords = vector4(1654.959, 2545.535, 45.564, 230.436)
        },
        {
            animation = "lean",
            coords = vector4(1697.106, 2525.558, 45.564, 187.208)
        },
        {
            animation = "sitchair4",
            coords = vector4(1673.084, 2519.823, 45.564, 229.542)
        },
        {
            animation = "sitchair",
            coords = vector4(1666.029, 2511.367, 45.564, 233.888)
        },
        {
            animation = "sitchair4",
            coords = vector4(1691.229, 2509.635, 45.564, 52.432)
        },
        {
            animation = "finger2",
            coords = vector4(1770.59, 2536.064, 45.564, 258.113)
        },
        {
            animation = "smoke",
            coords = vector4(1792.45, 2584.37, 45.56, 276.24)
        },
        {
            animation = "smoke",
            coords = vector4(1768.33, 2566.08, 45.56, 176.83)
        },
        {
            animation = "smoke",
            coords = vector4(1696.09, 2469.4, 45.56, 1.4)
        }
    }
}

Config.CanteenItems = {
    {
        name = "sandwich",
        price = 4,
        count = 50,
    },
    {
        name = "water_bottle",
        price = 4,
        count = 50,
    }
}
