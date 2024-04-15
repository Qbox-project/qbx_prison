return {
    useTarget = true, -- Use ox_target interactions
    inJailMoney = 80,
    takePhoto = true,
    gateCrack = 'gatecrack',

    jobs = {
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
    },

    introMessages = {
        locale('success.and_here_we_go_again'),
        locale('success.back_to_square_one'),
        locale('success.ready_to_have_some_fun'),
        locale('success.find_a_cozy_bed'),
        locale('success.friendly_neighborhood_troublemaker'),
        locale('success.back_to_the_ol_ball_and_chain'),
        locale('success.insert_sad_face'),
    },

    uniforms = {
        male = {
            outfitData = {
                ['t-shirt'] = {item = 15, texture = 0},
                ['torso2'] = {item = 345, texture = 0},
                ['arms'] = {item = 19, texture = 0},
                ['pants'] = {item = 3, texture = 7},
                ['shoes'] = {item = 1, texture = 0},
            }
        },
        female = {
            outfitData = {
                ['t-shirt'] = {item = 14, texture = 0},
                ['torso2'] = {item = 370, texture = 0},
                ['arms'] = {item = 0, texture = 0},
                ['pants'] = {item = 0, texture = 12},
                ['shoes'] = {item = 1, texture = 0},
            }
        },
    },

    locations = {
        prison = {
            {label = 'Prison', coords = vec3(1678.9, 2513.4, 45.6)},
        },
        takePhoto = {
            coords = vec3(402.9, -996.7, -100.0)
        },
        freedom = {
            coords = vec4(1775.73, 2551.97, 44.60, 85.57)
        },
        outside = {
            coords = vec4(1848.13, 2586.05, 44.67, 269.5)
        },
        yard = {
            coords = vec4(1765.67, 2565.91, 44.56, 1.5)
        },
        middle = {
            coords = vec3(1693.33, 2569.51, 44.55)
        },
        shop = {
            coords = vec4(1752.99, 2566.99, 44.60, 231.94)
        },
        spawns = {
            { coords = vec4(1745.77, 2489.61, 50.41, 212.01), animation = 'bumsleep' },
            { coords = vec4(1751.86, 2492.73, 50.44, 213.77), animation = 'lean' },
            { coords = vec4(1760.82, 2498.14, 50.42, 208.26), animation = 'sitchair4' },
            { coords = vec4(1754.85, 2494.59, 45.82, 212.49), animation = 'finger2' },
            { coords = vec4(1748.84, 2491.35, 45.80, 203.43), animation = 'smoke' }
        }
    },

    canteenItems = {
        {
            name = "burger",
            price = 4,
            count = 50,
        },
        {
            name = "water",
            price = 4,
            count = 50,
        }
    }
}
