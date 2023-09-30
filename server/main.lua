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

RegisterNetEvent('prison:server:SecurityLockdown', function()
    TriggerClientEvent("prison:client:SetLockDown", -1, true)
    for _, v in pairs(exports.qbx_core:GetPlayers()) do
        local player = exports.qbx_core:GetPlayer(v)
        if player then
            if player.PlayerData.job.name == "police" and player.PlayerData.job.onduty then
                TriggerClientEvent("prison:client:PrisonBreakAlert", v)
            end
        end
	end
end)

RegisterNetEvent('prison:server:SetGateHit', function(key)
    TriggerClientEvent("prison:client:SetGateHit", -1, key, true)
    if math.random(1, 100) <= 50 then
        for _, v in pairs(exports.qbx_core:GetPlayers()) do
            local player = exports.qbx_core:GetPlayer(v)
            if player then
                if player.PlayerData.job.type == "leo" and player.PlayerData.job.onduty then
                    TriggerClientEvent("prison:client:PrisonBreakAlert", v)
                end
            end
        end
    end
end)

RegisterNetEvent('prison:server:CheckRecordStatus', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    local criminalRecord = player.PlayerData.metadata.criminalrecord
    local currentDate = os.date("*t")

    if (criminalRecord.date.month + 1) == 13 then
        criminalRecord.date.month = 0
    end

    if criminalRecord.hasRecord then
        if currentDate.month == (criminalRecord.date.month + 1) or currentDate.day == (criminalRecord.date.day - 1) then
            criminalRecord.hasRecord = false
            criminalRecord.date = nil
        end
    end
end)

RegisterNetEvent('prison:server:JailAlarm', function()
    if alarmActivated then return end
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    local middle = vec2(Config.Locations.middle.coords.x, Config.Locations.middle.coords.y)
    if #(coords.xy - middle) < 200 then return error('"prison:server:JailAlarm" triggered whilst the player was too close to the prison, cancelled event') end
    TriggerClientEvent('prison:client:JailAlarm', -1, true)
    SetTimeout(5 * 60000, function()
        TriggerClientEvent('prison:client:JailAlarm', -1, false)
    end)
end)

RegisterNetEvent('prison:server:CheckChance', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or player.PlayerData.metadata.injail == 0 or gotItems[src] then return end
    local chance = math.random(100)
    local odd = math.random(100)
    if chance ~= odd then return end
    if not player.Functions.AddItem('phone', 1) then return end
    TriggerClientEvent('inventory:client:ItemBox', src, exports.ox_inventory:Items()['phone'], 'add')
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.found_phone'), 'success')
    gotItems[src] = true
end)

lib.callback.register('prison:server:IsAlarmActive', function()
    return alarmActivated
end)
