local gotItems = {}
local alarmActivated = false

local function setJailStatus(src, jailTime)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    player.Functions.SetMetaData("injail", jailTime)
    if jailTime > 0 then
        if player.PlayerData.job.name ~= "unemployed" then
            player.Functions.SetJob("unemployed")
            TriggerClientEvent('QBCore:Notify', src, Lang:t("info.lost_job"))
        end
    else
        gotItems[src] = nil
    end
end

RegisterNetEvent('prison:server:SetJailStatus', function(jailTime)
    setJailStatus(source, jailTime)
end)

local function jailPlayer(src, minutes)
    exports.qbx_core:Notify(src, Lang:t("error.injail", {Time = minutes}))
    exports.qbx_core:Notify(src, Lang:t("info.seized_property"))
    exports.ox_inventory:ConfiscateInventory(src)

    local player = exports.qbx_core:GetPlayer(src)
    player.Functions.AddMoney('cash', 80)

    setJailStatus(src, minutes)
    TriggerClientEvent('qbx_prison:client:playerJailed', src)
end

exports('JailPlayer', jailPlayer)

local function releasePlayer(src)
    setJailStatus(src, 0)
    exports.ox_inventory:ReturnInventory(src)
    exports.qbx_core:Notify(src, Lang:t("info.received_property"))
    TriggerClientEvent('qbx_prison:client:playerReleased', src)
end

exports('ReleasePlayer', releasePlayer)

local function securityLockdown()
    TriggerClientEvent("prison:client:SetLockDown", -1, true)
    for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
        if player.PlayerData.job.type == "leo" and player.PlayerData.job.onduty then
            TriggerClientEvent("prison:client:PrisonBreakAlert", player.PlayerData.source)
        end
	end
end

RegisterNetEvent('qbx_prison:server:playerEscaped', function()
    securityLockdown()
    setJailStatus(source, 0)
end)

local function setGateHit(key)
    TriggerClientEvent("prison:client:SetGateHit", -1, key, true)
    if math.random(1, 100) <= 50 then
        for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
            if player.PlayerData.job.type == "leo" and player.PlayerData.job.onduty then
                TriggerClientEvent("prison:client:PrisonBreakAlert", player.PlayerData.source)
            end
        end
    end
end

RegisterNetEvent('qbx_prison:server:onGateHackDone', function(success, currentGate, gateKey)
    if source == '' then return end
    if success then
        setGateHit(currentGate)
        exports.ox_doorlock:setDoorState(gateKey, 0)
    else
        securityLockdown()
    end
end)

RegisterNetEvent('prison:server:JailAlarm', function()
    if alarmActivated then return end
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    local middle = Config.Locations.middle.coords
    if #(coords.xy - middle.xy) < 200 then return error('"prison:server:JailAlarm" triggered whilst the player was too close to the prison, cancelled event') end
    alarmActivated = true
    TriggerClientEvent('prison:client:JailAlarm', -1, true)
    SetTimeout(5 * 60000, function()
        alarmActivated = false
        TriggerClientEvent('prison:client:JailAlarm', -1, false)
    end)
end)

---When player is finished with a job, they have a chance to find a reward
RegisterNetEvent('qbx_prison:server:completedJob', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or player.PlayerData.metadata.injail == 0 then return end
    if Config.Jobs.electrician.canOnlyGetOneReward and gotItems[src] then return end
    local chance = math.random(100)
    if chance > Config.Jobs.electrician.rewardChance then return end
    if not player.Functions.AddItem(Config.Jobs.electrician.reward, 1) then return end
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.found_item', {item = Config.Jobs.electrician.reward}), 'success')
    gotItems[src] = true
end)

lib.callback.register('prison:server:IsAlarmActive', function()
    return alarmActivated
end)

exports.ox_inventory:RegisterShop('Canteen', {
    name = 'Prison Canteen',
    inventory = Config.CanteenItems,
})

---@deprecated do not call this event
RegisterNetEvent('prison:server:SaveJailItems', function()
    lib.print.error(GetInvokingResource(), "invoked deprecated prison:server:SaveJailedItems event. Event has no effect.")
end)

---@deprecated do not call this event
RegisterNetEvent('prison:server:GiveJailItems', function()
    lib.print.error(GetInvokingResource(), "invoked deprecated prison:server:GiveJailItems event. Event has no effect.")
end)

---@deprecated No replacement. If valid use case, contact Qbox team to request an export or event be exposed
RegisterNetEvent('prison:server:SetGateHit', function(key)
    lib.print.error(GetInvokingResource(), "invoked deprecated event prison:server:SetGateHit. Event has no effect.")
end)

---@deprecated Do not call this event
RegisterNetEvent('prison:server:SecurityLockdown', function()
    lib.print.error(GetInvokingResource(), "invoked prison:server:SecurityLockdown event. Event has no effect.")
end)

---@deprecated Do not call this event
RegisterNetEvent('prison:server:CheckChance', function()
    lib.print.error(GetInvokingResource(), "invoked deprecated prison:server:CheckChance event. Event has no effect.")
end)