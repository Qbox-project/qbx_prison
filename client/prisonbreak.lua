local currentGate = 0
local requiredItemsShowed = false
local requiredItems = {}
local inRange = false
local securityLockdown = false
local Gates = {
    [1] = {
        gatekey = 13,
        coords = vector3(1845.99, 2604.7, 45.58),
        hit = false,
    },
    [2] = {
        gatekey = 14,
        coords = vector3(1819.47, 2604.67, 45.56),
        hit = false,
    },
    [3] = {
        gatekey = 15,
        coords = vector3(1804.74, 2616.311, 45.61),
        hit = false,
    }
}

-- Functions

--- This will be triggered once a hack is done on a gate
--- @param success boolean
local function OnHackDone(success)
    Config.OnHackDone(success, currentGate, Gates[currentGate])
end

-- Events

RegisterNetEvent('electronickit:UseElectronickit', function()
    if currentGate ~= 0 and not securityLockdown and not Gates[currentGate].hit then
        local hasItem = exports.qbx_core:HasItem("gatecrack")
        if hasItem then
            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
            if lib.progressBar({
                duration = math.random(5000, 10000),
                label = Lang:t("info.connecting_device"),
                useWhileDead = false,
                canCancel = true,
                anim = {
                    dict = "anim@gangops@facility@servers@",
                    clip = "hotwire",
                    flag = 16
                },
                disable = {
                    move = true,
                    car = true,
                    mouse = false,
                    combat = true
                }
            }) then
                TriggerEvent("mhacking:show")
                TriggerEvent("mhacking:start", math.random(5, 9), math.random(10, 18), OnHackDone)
            else
                exports.qbx_core:Notify(Lang:t("error.cancelled"), "error")
            end

            StopAnimTask(cache.ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
        else
            exports.qbx_core:Notify(Lang:t("error.item_missing"), "error")
        end
    end
end)

RegisterNetEvent('prison:client:SetLockDown', function(isLockdown)
    securityLockdown = isLockdown
    if not securityLockdown or not inJail then return end
    TriggerEvent("chat:addMessage", {
        color = {255, 0, 0},
        multiline = true,
        args = {"HOSTAGE", Lang:t("error.security_activated")}
    })
end)

RegisterNetEvent('prison:client:PrisonBreakAlert', function()
    local coords = vector3(Config.Locations["middle"].coords.x, Config.Locations["middle"].coords.y, Config.Locations["middle"].coords.z)
    local alertData = {title = Lang:t("info.police_alert_title"), coords = {x = coords.x, y = coords.y, z = coords.z}, description = Lang:t("info.police_alert_description")}
    TriggerEvent("qb-phone:client:addPoliceAlert", alertData)
    TriggerEvent('police:client:policeAlert', coords, Lang:t("info.police_alert_description"))

    local BreakBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    TriggerServerEvent('prison:server:JailAlarm')
    SetBlipSprite(BreakBlip , 161)
    SetBlipScale(BreakBlip , 3.0)
    SetBlipColour(BreakBlip, 3)
    PulseBlip(BreakBlip)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", false, 0, true)
    Wait(100)
    PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
    Wait(100)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", false, 0, true)
    Wait(100)
    PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
    Wait((1000 * 60 * 5))
    RemoveBlip(BreakBlip)
end)

RegisterNetEvent('prison:client:SetGateHit', function(key, isHit)
    Gates[key].hit = isHit
end)

RegisterNetEvent('prison:client:JailAlarm', function(toggle)
    if toggle then
        local alarmIpl = GetInteriorAtCoordsWithType(1787.004,2593.1984,45.7978, "int_prison_main")

        RefreshInterior(alarmIpl)
        EnableInteriorProp(alarmIpl, "prison_alarm")

        CreateThread(function()
            while not PrepareAlarm("PRISON_ALARMS") do
                Wait(100)
            end
            StartAlarm("PRISON_ALARMS", true)
        end)
    else
        local alarmIpl = GetInteriorAtCoordsWithType(1787.004,2593.1984,45.7978, "int_prison_main")

        RefreshInterior(alarmIpl)
        DisableInteriorProp(alarmIpl, "prison_alarm")

        CreateThread(function()
            while not PrepareAlarm("PRISON_ALARMS") do
                Wait(100)
            end
            StopAllAlarms(true)
        end)
    end
end)

-- Threads

CreateThread(function()
    Wait(500)
    requiredItems = {
        [1] = {name = exports.ox_inventory:Items()["electronickit"]["name"], image = exports.ox_inventory:Items()["electronickit"]["image"]},
        [2] = {name = exports.ox_inventory:Items()["gatecrack"]["name"], image = exports.ox_inventory:Items()["gatecrack"]["image"]},
    }
    while true do
        inRange = false
        currentGate = 0
        local sleep = 1000
        if LocalPlayer.state.isLoggedIn then
            if QBX.PlayerData.PlayerJob.type ~= "leo" then
                local pos = GetEntityCoords(cache.ped)
                for k in pairs(Gates) do
                    local dist =  #(pos - Gates[k].coords)
                    if dist < 1.5 then
                        currentGate = k
                        inRange = true
                        if securityLockdown then
                            sleep = 0
                            DrawText3D(Gates[k].coords, "~r~SYSTEM LOCKDOWN")
                        elseif Gates[k].hit then
                            sleep = 0
                            DrawText3D(Gates[k].coords, "SYSTEM BREACH")
                        elseif not requiredItemsShowed then
                            requiredItemsShowed = true
                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                        end
                    end
                end

                if not inRange then
                    if requiredItemsShowed then
                        requiredItemsShowed = false
                        TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local pos = GetEntityCoords(cache.ped, true)
        if #(pos.xy - vec2(Config.Locations["middle"].coords.x, Config.Locations["middle"].coords.y)) > 200 and inJail then
            inJail = false
            jailTime = 0
            RemoveBlip(currentBlip)
            RemoveBlip(CellsBlip)
            RemoveBlip(TimeBlip)
            RemoveBlip(ShopBlip)
            TriggerServerEvent("prison:server:SecurityLockdown")
            TriggerEvent("prison:client:PrisonBreakAlert")
            TriggerServerEvent("prison:server:SetJailStatus", 0)
            TriggerServerEvent("prison:server:GiveJailItems", true)
            exports.qbx_core:Notify(Lang:t("error.escaped"), "error")
        end
        Wait(1000)
    end
end)
