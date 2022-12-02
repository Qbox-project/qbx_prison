Config = Config or {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use ox_target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

local isServer = IsDuplicityVersion()

if not isServer then
    --- This function will be triggered once the hack is done
    --- @param success boolean
    --- @param currentGate number
    --- @param gateData table
    --- @return nil
    function Config.OnHackDone(success, currentGate, gateData)
        if success then
            TriggerServerEvent("prison:server:SetGateHit", currentGate)
            TriggerServerEvent('qb-doorlock:server:updateState', gateData.gatekey, false, false, false, true)
        else
            TriggerServerEvent("prison:server:SecurityLockdown")
        end

        TriggerEvent('mhacking:hide')
    end
end

Config.Jobs = {
    ["electrician"] = "Electrician"
}

Config.Uniforms ={
    ['male'] = {
        outfitData ={
            ['t-shirt'] = {item = 15, texture = 0},
            ['torso2'] = {item = 345, texture = 0},
            ['arms'] = {item = 19, texture = 0},
            ['pants'] = {item = 3, texture = 7},
            ['shoes'] = {item = 1, texture = 0},
        }
    },
    ['female'] = {
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
    jobs = {
        ["electrician"] = {
            [1] = {
                coords = vec3(1761.6, 2540.25, 45.7),
                size = vec3(1, 1, 2.0),
                rotation = 0.0
            }
        }
    },
    ["freedom"] = {
        ped = {
            model = joaat('s_m_m_armoured_01'),
            coords = vec4(1775.25, 2553.5, 44.57, 94.25)
        },
        zone = {
            coords = vec3(1775.25, 2553.5, 45.75),
            size = vec3(1.5, 1.5, 2.25),
            rotation = 0.0
        }
    },
    ["outside"] = {
        coords = vec4(1848.13, 2586.05, 44.67, 269.5)
    },
    ["yard"] = {
        coords = vec4(1765.67, 2565.91, 44.56, 1.5)
    },
    ["middle"] = {
        coords = vec4(1693.33, 2569.51, 44.55, 123.5)
    },
    ["shop"] = {
        ped = {
            model = joaat('s_m_m_armoured_01'),
            coords = vec4(1775.0, 2550.5, 44.57, 94.25)
        },
        zone = {
            coords = vec3(1775.0, 2550.5, 45.5),
            size = vec3(1.5, 1.25, 2.0),
            rotation = 0.0
        }
    },
    spawns = {
        [1] = {
            animation = "bumsleep",
            coords = vec4(1661.046, 2524.681, 45.564, 260.545)
        },
        [2] = {
            animation = "lean",
            coords = vec4(1650.812, 2540.582, 45.564, 230.436)
        },
        [3] = {
            animation = "lean",
            coords = vec4(1654.959, 2545.535, 45.564, 230.436)
        },
        [4] = {
            animation = "lean",
            coords = vec4(1697.106, 2525.558, 45.564, 187.208)
        },
        [5] = {
            animation = "sitchair4",
            coords = vec4(1673.084, 2519.823, 45.564, 229.542)
        },
        [6] = {
            animation = "sitchair",
            coords = vec4(1666.029, 2511.367, 45.564, 233.888)
        },
        [7] = {
            animation = "sitchair4",
            coords = vec4(1691.229, 2509.635, 45.564, 52.432)
        },
        [8] = {
            animation = "finger2",
            coords = vec4(1770.59, 2536.064, 45.564, 258.113)
        },
        [9] = {
            animation = "smoke",
            coords = vec4(1792.45, 2584.37, 45.56, 276.24)
        },
        [10] = {
            animation = "smoke",
            coords = vec4(1768.33, 2566.08, 45.56, 176.83)
        },
        [11] = {
            animation = "smoke",
            coords = vec4(1696.09, 2469.4, 45.56, 1.4)
        }
    }
}

Config.CanteenItems = {
    [1] = {
        name = "sandwich",
        price = 4,
        amount = 50,
        info = {},
        type = "item",
        slot = 1
    },
    [2] = {
        name = "water_bottle",
        price = 4,
        amount = 50,
        info = {},
        type = "item",
        slot = 2
    }
}

Config.Gates = {
    [1] = {
        coords = vec3(1845.99, 2604.7, 45.58)
    },
    [2] = {
        coords = vec3(1819.47, 2604.67, 45.56)
    },
    [3] = {
        coords = vec3(1804.74, 2616.311, 45.61)
    }
}