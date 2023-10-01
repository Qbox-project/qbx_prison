local gotItems = {}
local alarmActivated = false

RegisterNetEvent('prison:server:SetJailStatus', function(jailTime)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    player.Functions.SetMetaData("injail", jailTime)
    if jailTime > 0 then
        if player.PlayerData.job.name ~= "unemployed" then
            player.Functions.SetJob("unemployed")
            TriggerClientEvent('QBCore:Notify', src, Lang:t("info.lost_job"))
        end
    else
        gotItems[source] = nil
    end
end)

RegisterNetEvent('prison:server:SaveJailItems', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    if not player.PlayerData.metadata.jailitems or table.type(player.PlayerData.metadata.jailitems) == "empty" then
        player.Functions.SetMetaData("jailitems", player.PlayerData.items)
        player.Functions.AddMoney('cash', 80)
        Wait(2000)
        player.Functions.ClearInventory()
    end
end)

RegisterNetEvent('prison:server:GiveJailItems', function(escaped)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    if escaped then
        player.Functions.SetMetaData("jailitems", {})
        return
    end
    for _, v in pairs(player.PlayerData.metadata.jailitems) do
        player.Functions.AddItem(v.name, v.amount, false, v.info)
    end
    player.Functions.SetMetaData("jailitems", {})
end)

RegisterNetEvent('prison:server:ResetJailItems', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    player.Functions.SetMetaData("jailitems", {})
end)

local function securityLockdown()
    TriggerClientEvent("prison:client:SetLockDown", -1, true)
    for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
        if player.PlayerData.job.type == "leo" and player.PlayerData.job.onduty then
            TriggerClientEvent("prison:client:PrisonBreakAlert", player.PlayerData.source)
        end
	end
end

RegisterNetEvent('prison:server:SecurityLockdown', securityLockdown)

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

---@deprecated No replacement. If valid use case, contact Qbox team to request an export or event be exposed
RegisterNetEvent('prison:server:SetGateHit', function(key)
    lib.print.warn(GetInvokingResource(), " invoked deprecated event prison:server:SetGateHit")
    setGateHit(key)
end)

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

---TODO: Seems like this should either be a callback or handling an event named 'jobFinished' or something similar
---In any case. This construct doesn't seem like the correct structure to handle this.
---When player is finished with a job, they have a chance to find a phone
RegisterNetEvent('prison:server:CheckChance', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or player.PlayerData.metadata.injail == 0 or gotItems[src] then return end
    local chance = math.random(100)
    if chance ~= 1 then return end
    if not player.Functions.AddItem('phone', 1) then return end
    TriggerClientEvent('inventory:client:ItemBox', src, exports.ox_inventory:Items()['phone'], 'add')
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.found_phone'), 'success')
    gotItems[src] = true
end)

lib.callback.register('prison:server:IsAlarmActive', function()
    return alarmActivated
end)
