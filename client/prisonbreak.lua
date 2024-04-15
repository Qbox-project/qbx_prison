local currentGate = 0
local requiredItems = {}
local securityLockdown = false
local config = require('config.shared')
local gates = {
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
local function onHackDone(success)
    TriggerServerEvent('qbx_prison:server:onGateHackDone', success, currentGate, gates[currentGate].gatekey)
    TriggerEvent('mhacking:hide')
end

-- Events

RegisterNetEvent('electronickit:UseElectronickit', function()
    if currentGate == 0 or securityLockdown or not gates[currentGate].hit then return end
    local hasItem = exports.ox_inventory:Search('count', config.gateCrack)
    if not hasItem then
        exports.qbx_core:Notify(locale("error.item_missing"), "error")
        return
    end

    TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    if lib.progressBar({
        duration = math.random(5000, 10000),
        label = locale("info.connecting_device"),
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
        TriggerEvent("mhacking:start", math.random(5, 9), math.random(10, 18), onHackDone)
    else
        exports.qbx_core:Notify(locale("error.cancelled"), "error")
    end

    StopAnimTask(cache.ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
end)

RegisterNetEvent('prison:client:SetLockDown', function(isLockdown)
    securityLockdown = isLockdown
    if not securityLockdown or not InJail then return end
    TriggerEvent("chat:addMessage", {
        color = {255, 0, 0},
        multiline = true,
        args = {"HOSTAGE", locale("error.security_activated")}
    })
end)

RegisterNetEvent('prison:client:PrisonBreakAlert', function()
    local coords = config.locations.middle.coords
    local alertData = {title = locale("info.police_alert_title"), coords = {x = coords.x, y = coords.y, z = coords.z}, description = locale("info.police_alert_description")}
    TriggerEvent("qb-phone:client:addPoliceAlert", alertData)
    TriggerEvent('police:client:policeAlert', coords, locale("info.police_alert_description"))

    local breakBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    TriggerServerEvent('prison:server:JailAlarm')
    SetBlipSprite(breakBlip , 161)
    SetBlipScale(breakBlip , 3.0)
    SetBlipColour(breakBlip, 3)
    PulseBlip(breakBlip)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", false, 0, true)
    Wait(100)
    PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
    Wait(100)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", false, 0, true)
    Wait(100)
    PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
    Wait((1000 * 60 * 5))
    RemoveBlip(breakBlip)
end)

RegisterNetEvent('prison:client:SetGateHit', function(key, isHit)
    gates[key].hit = isHit
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

local function createGateZones()
    requiredItems = {
        [1] = {name = exports.ox_inventory:Items().electronickit.name, image = exports.ox_inventory:Items().electronickit.image},
        [2] = {name = exports.ox_inventory:Items().gatecrack.name, image = exports.ox_inventory:Items().gatecrack.image},
    }
    currentGate = 0
    for i = 1, #gates do
        lib.zones.sphere({
            coords = gates[i].coords,
            radius = 1.5,
            onEnter = function()
                if QBX.PlayerData.job.type == "leo" then return end
                currentGate = i
                TriggerEvent('inventory:client:requiredItems', requiredItems, true)
            end,
            onLeave = function()
                if QBX.PlayerData.job.type == "leo" then return end
                TriggerEvent('inventory:client:requiredItems', requiredItems, false)
            end,
            inside = function()
                if securityLockdown then
                    qbx.drawText3d({ text = "~r~" .. locale('info.system_lockdown'), coords = gates[i].coords })
                elseif gates[i].hit then
                    qbx.drawText3d({ text = locale('info.system_breach'), coords = gates[i].coords })
                end
            end,
        })
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    createGateZones()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', createGateZones)

local function checkForEscape()
    if not InJail then return end
    InJail = false
    JailTime = 0
    RemoveBlip(CurrentBlip)
    RemoveBlip(CellsBlip)
    RemoveBlip(TimeBlip)
    RemoveBlip(ShopBlip)
    TriggerEvent("prison:client:PrisonBreakAlert")
    exports.qbx_core:Notify(locale("error.escaped"), "error")
    TriggerServerEvent('qbx_prison:server:playerEscaped')
end

lib.zones.sphere({
    coords = config.locations.middle.coords,
    radius = 200,
    onExit = checkForEscape,
})
