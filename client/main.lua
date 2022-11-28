QBCore = exports['qb-core']:GetCoreObject() -- Used Globally
inJail = false
jailTime = 0
currentJob = nil
CellsBlip = nil
TimeBlip = nil
ShopBlip = nil
local insidecanteen = false
local insidefreedom = false
local canteen_ped = 0
local freedom_ped = 0

-- Functions

--- This will draw 3d text at the given location with the given text
--- @param x number
--- @param y number
--- @param z number
--- @param text string
--- @return nil
local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 215)
    SetTextCentre(true)
    SetDrawOrigin(x, y, z, 0)

    AddTextComponentSubstringPlayerName(text)
    BeginTextCommandDisplayText("STRING")
    EndTextCommandDisplayText(0.0, 0.0)

    local factor = (string.len(text)) / 370

    DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

--- This will create the blips for the cells, time check and shop
--- @return nil
local function CreateCellsBlip()
    if CellsBlip then
        RemoveBlip(CellsBlip)
    end

    CellsBlip = AddBlipForCoord(Config.Locations["yard"].coords.x, Config.Locations["yard"].coords.y, Config.Locations["yard"].coords.z)

    SetBlipSprite(CellsBlip, 238)
    SetBlipDisplay(CellsBlip, 4)
    SetBlipScale(CellsBlip, 0.8)
    SetBlipAsShortRange(CellsBlip, true)
    SetBlipColour(CellsBlip, 4)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Lang:t("info.cells_blip"))
    EndTextCommandSetBlipName(CellsBlip)

    if TimeBlip then
        RemoveBlip(TimeBlip)
    end

    TimeBlip = AddBlipForCoord(Config.Locations["freedom"].zone.coords.x, Config.Locations["freedom"].zone.coords.y, Config.Locations["freedom"].zone.coords.z)

    SetBlipSprite(TimeBlip, 466)
    SetBlipDisplay(TimeBlip, 4)
    SetBlipScale(TimeBlip, 0.8)
    SetBlipAsShortRange(TimeBlip, true)
    SetBlipColour(TimeBlip, 4)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Lang:t("info.freedom_blip"))
    EndTextCommandSetBlipName(TimeBlip)

    if ShopBlip then
        RemoveBlip(ShopBlip)
    end

    ShopBlip = AddBlipForCoord(Config.Locations["shop"].zone.coords.x, Config.Locations["shop"].zone.coords.y, Config.Locations["shop"].zone.coords.z)

    SetBlipSprite(ShopBlip, 52)
    SetBlipDisplay(ShopBlip, 4)
    SetBlipScale(ShopBlip, 0.5)
    SetBlipAsShortRange(ShopBlip, true)
    SetBlipColour(ShopBlip, 0)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Lang:t("info.canteen_blip"))
    EndTextCommandSetBlipName(ShopBlip)
end

-- Add clothes to prisioner
local function ApplyClothes()
    if DoesEntityExist(cache.ped) then
        CreateThread(function()
            SetPedArmour(cache.ped, 0)
            ClearPedBloodDamage(cache.ped)
            ResetPedVisibleDamage(cache.ped)
            ClearPedLastWeaponDamage(cache.ped)
            ResetPedMovementClipset(cache.ped, 0)

            local gender = QBCore.Functions.GetPlayerData().charinfo.gender

            if gender == 0 then
                TriggerEvent('qb-clothing:client:loadOutfit', Config.Uniforms.male)
            else
                TriggerEvent('qb-clothing:client:loadOutfit', Config.Uniforms.female)
            end
        end)
    end
end

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.metadata["injail"] > 0 then
            TriggerEvent("prison:client:Enter", PlayerData.metadata["injail"])
        end
    end)

    QBCore.Functions.TriggerCallback('prison:server:IsAlarmActive', function(active)
        if active then
            TriggerEvent('prison:client:JailAlarm', true)
        end
    end)

    if DoesEntityExist(canteen_ped) or DoesEntityExist(freedom_ped) then
        return
    end

    local freedomData = Config.Locations["freedom"]

    lib.requestModel(freedomData.ped.model)

    freedom_ped = CreatePed(0, freedomData.ped.model, freedomData.ped.coords.x, freedomData.ped.coords.y, freedomData.ped.coords.z, freedomData.ped.coords.w, false, true)

    FreezeEntityPosition(freedom_ped, true)
    SetEntityInvincible(freedom_ped, true)
    SetBlockingOfNonTemporaryEvents(freedom_ped, true)
    TaskStartScenarioInPlace(freedom_ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)

    local shopData = Config.Locations["shop"]

    lib.requestModel(shopData.ped.model)

    canteen_ped = CreatePed(0, shopData.ped.model, shopData.ped.coords.x, shopData.ped.coords.y, shopData.ped.coords.z, shopData.ped.coords.w, false, true)

    FreezeEntityPosition(canteen_ped, true)
    SetEntityInvincible(canteen_ped, true)
    SetBlockingOfNonTemporaryEvents(canteen_ped, true)
    TaskStartScenarioInPlace(canteen_ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)

    if not Config.UseTarget then return end

    exports['qb-target']:AddTargetEntity(freedom_ped, {
        options = {
            {
                type = "client",
                event = "prison:client:Leave",
                icon = 'fas fa-clipboard',
                label = Lang:t("info.target_freedom_option"),
                canInteract = function()
                    return inJail
                end
            }
        },
        distance = 2.5
    })
    exports['qb-target']:AddTargetEntity(canteen_ped, {
        options = {
            {
                type = "client",
                event = "prison:client:canteen",
                icon = 'fas fa-clipboard',
                label = Lang:t("info.target_canteen_option"),
                canInteract = function()
                    return inJail
                end
            }
        },
        distance = 2.5
    })
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    Wait(100)

    if LocalPlayer.state['isLoggedIn'] then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if PlayerData.metadata["injail"] > 0 then
                TriggerEvent("prison:client:Enter", PlayerData.metadata["injail"])
            end
        end)
    end

    QBCore.Functions.TriggerCallback('prison:server:IsAlarmActive', function(active)
        if not active then
            return
        end

        TriggerEvent('prison:client:JailAlarm', true)
    end)

    if DoesEntityExist(canteen_ped) or DoesEntityExist(freedom_ped) then
        return
    end

    local freedomData = Config.Locations["freedom"]

    lib.requestModel(freedomData.ped.model)

    freedom_ped = CreatePed(0, freedomData.ped.model, freedomData.ped.coords.x, freedomData.ped.coords.y, freedomData.ped.coords.z, freedomData.ped.coords.w, false, true)

    FreezeEntityPosition(freedom_ped, true)
    SetEntityInvincible(freedom_ped, true)
    SetBlockingOfNonTemporaryEvents(freedom_ped, true)
    TaskStartScenarioInPlace(freedom_ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)

    local shopData = Config.Locations["shop"]

    lib.requestModel(shopData.ped.model)

    canteen_ped = CreatePed(0, shopData.ped.model, shopData.ped.coords.x, shopData.ped.coords.y, shopData.ped.coords.z, shopData.ped.coords.w, false, true)

    FreezeEntityPosition(canteen_ped, true)
    SetEntityInvincible(canteen_ped, true)
    SetBlockingOfNonTemporaryEvents(canteen_ped, true)
    TaskStartScenarioInPlace(canteen_ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)

    if not Config.UseTarget then
        return
    end

    exports['qb-target']:AddTargetEntity(freedom_ped, {
        options = {
            {
                type = "client",
                event = "prison:client:Leave",
                icon = 'fas fa-clipboard',
                label = Lang:t("info.target_freedom_option"),
                canInteract = function()
                    return inJail
                end
            }
        },
        distance = 2.5
    })
    exports['qb-target']:AddTargetEntity(canteen_ped, {
        options = {
            {
                type = "client",
                event = "prison:client:canteen",
                icon = 'fas fa-clipboard',
                label = Lang:t("info.target_canteen_option"),
                canInteract = function()
                    return inJail
                end
            }
        },
        distance = 2.5
    })
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    inJail = false
    currentJob = nil

    RemoveBlip(currentBlip)
end)

RegisterNetEvent('prison:client:Enter', function(time)
    local invokingResource = GetInvokingResource()

    if invokingResource and invokingResource ~= 'qb-policejob' and invokingResource ~= 'qb-ambulancejob' and invokingResource ~= GetCurrentResourceName() then
        -- Use QBCore.Debug here for a quick and easy way to print to the console to grab your attention with this message
        QBCore.Debug({('Player with source %s tried to execute prison:client:Enter manually or from another resource which is not authorized to call this, invokedResource: %s'):format(cache.serverId, invokingResource)})
        return
    end

    QBCore.Functions.Notify( Lang:t("error.injail", {Time = time}), "error")

    TriggerEvent("chat:addMessage", {
        color = {3, 132, 252},
        multiline = true,
        args = {"SYSTEM", Lang:t("info.seized_property")}
    })

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end

    local RandomStartPosition = Config.Locations.spawns[math.random(1, #Config.Locations.spawns)]

    SetEntityCoords(cache.ped, RandomStartPosition.coords.x, RandomStartPosition.coords.y, RandomStartPosition.coords.z - 0.9, 0, 0, 0, false)
    SetEntityHeading(cache.ped, RandomStartPosition.coords.w)

    Wait(500)

    TriggerEvent('animations:client:EmoteCommandStart', {RandomStartPosition.animation})

    inJail = true
    jailTime = time

    local tempJobs = {}
    local i = 1

    for k in pairs(Config.Locations.jobs) do
        tempJobs[i] = k
        i += 1
    end

    currentJob = tempJobs[math.random(1, #tempJobs)]

    CreateJobBlip(true)
    ApplyClothes()

    TriggerServerEvent("prison:server:SetJailStatus", jailTime)
    TriggerServerEvent("prison:server:SaveJailItems", jailTime)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "jail", 0.5)

    CreateCellsBlip()

    Wait(2000)
    DoScreenFadeIn(1000)

    QBCore.Functions.Notify( Lang:t("error.do_some_work", {currentjob = Config.Jobs[currentJob] }), "error")
end)

RegisterNetEvent('prison:client:Leave', function()
    if not inJail then
        return
    end

    if jailTime > 0 then
        QBCore.Functions.Notify( Lang:t("info.timeleft", {
            JAILTIME = jailTime
        }))
    else
        jailTime = 0

        TriggerServerEvent("prison:server:SetJailStatus", 0)
        TriggerServerEvent("prison:server:GiveJailItems")
        TriggerEvent("chat:addMessage", {
            color = {3, 132, 252},
            multiline = true,
            args = {"SYSTEM", Lang:t("info.received_property")}
        })

        inJail = false

        RemoveBlip(currentBlip)
        RemoveBlip(CellsBlip)

        CellsBlip = nil

        RemoveBlip(TimeBlip)

        TimeBlip = nil

        RemoveBlip(ShopBlip)

        ShopBlip = nil

        QBCore.Functions.Notify(Lang:t("success.free_"))

        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Wait(10)
        end

        TriggerServerEvent('qb-clothes:loadPlayerSkin')

        SetEntityCoords(cache.ped, Config.Locations["outside"].coords.x, Config.Locations["outside"].coords.y, Config.Locations["outside"].coords.z, 0, 0, 0, false)
        SetEntityHeading(cache.ped, Config.Locations["outside"].coords.w)

        Wait(500)
        DoScreenFadeIn(1000)
    end
end)

RegisterNetEvent('prison:client:UnjailPerson', function()
    if jailTime > 0 then
        TriggerServerEvent("prison:server:SetJailStatus", 0)
        TriggerServerEvent("prison:server:GiveJailItems")
        TriggerEvent("chat:addMessage", {
            color = {3, 132, 252},
            multiline = true,
            args = {"SYSTEM", Lang:t("info.received_property")}
        })

        inJail = false

        RemoveBlip(currentBlip)
        RemoveBlip(CellsBlip)

        CellsBlip = nil

        RemoveBlip(TimeBlip)

        TimeBlip = nil

        RemoveBlip(ShopBlip)

        ShopBlip = nil

        QBCore.Functions.Notify(Lang:t("success.free_"))

        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Wait(10)
        end

        TriggerServerEvent('qb-clothes:loadPlayerSkin')

        SetEntityCoords(cache.ped, Config.Locations["outside"].coords.x, Config.Locations["outside"].coords.y, Config.Locations["outside"].coords.z, 0, 0, 0, false)
        SetEntityHeading(cache.ped, Config.Locations["outside"].coords.w)

        Wait(500)
        DoScreenFadeIn(1000)
    end
end)

RegisterNetEvent('prison:client:canteen', function()
    local ShopItems = {}

    ShopItems.label = "Prison Canteen"
    ShopItems.items = Config.CanteenItems
    ShopItems.slots = #Config.CanteenItems

    TriggerServerEvent("inventory:server:OpenInventory", "shop", "Canteenshop_" .. math.random(1, 99), ShopItems)
end)

-- Threads
CreateThread(function()
    while true do
        inRange = false
        currentGate = 0

        local sleep = 1000

        if LocalPlayer.state.isLoggedIn then
            if PlayerJob.name ~= "police" then
                local pos = GetEntityCoords(cache.ped)

                for k in pairs(Gates) do
                    local dist =  #(pos - Gates[k].coords)

                    if dist < 1.5 then
                        currentGate = k
                        inRange = true

                        if securityLockdown then
                            sleep = 0

                            DrawText3D(Gates[k].coords.x, Gates[k].coords.y, Gates[k].coords.z, "~r~SYSTEM LOCKDOWN")
                        elseif Gates[k].hit then
                            sleep = 0

                            DrawText3D(Gates[k].coords.x, Gates[k].coords.y, Gates[k].coords.z, "SYSTEM BREACH")
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    TriggerEvent('prison:client:JailAlarm', false)

    while true do
        local sleep = 1000

        if jailTime > 0 and inJail then
            Wait(1000 * 60)

            sleep = 0

            if jailTime > 0 and inJail then
                jailTime -= 1

                if jailTime <= 0 then
                    jailTime = 0

                    QBCore.Functions.Notify(Lang:t("success.timesup"), "success", 10000)
                end

                TriggerServerEvent("prison:server:SetJailStatus", jailTime)
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    if not Config.UseTarget then
        lib.zones.box({
            coords = Config.Locations["freedom"].zone.coords,
            size = Config.Locations["freedom"].zone.size,
            rotation = Config.Locations["freedom"].zone.rotation,
            onEnter = function(_)
                insidefreedom = true

                CreateThread(function()
                    while insidefreedom do
                        if IsControlJustReleased(0, 38) then
                            lib.hideTextUI()

                            TriggerEvent("prison:client:Leave")
                            break
                        end

                        Wait(0)
                    end
                end)

                lib.showTextUI('[E] - Check Time')
            end,
            onExit = function(_)
                insidefreedom = false

                lib.hideTextUI()
            end
        })
        lib.zones.box({
            coords = Config.Locations["shop"].zone.coords,
            size = Config.Locations["shop"].zone.size,
            rotation = Config.Locations["shop"].zone.rotation,
            onEnter = function(_)
                insidecanteen = true

                CreateThread(function()
                    while insidecanteen do
                        if IsControlJustReleased(0, 38) then
                            lib.hideTextUI()

                            TriggerEvent("prison:client:canteen")
                            break
                        end

                        Wait(0)
                    end
                end)

                lib.showTextUI('[E] - Open Canteen')
            end,
            onExit = function(_)
                insidecanteen = false

                lib.hideTextUI()
            end
        })
    end
end)