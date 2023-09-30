inJail = false
jailTime = 0
currentJob = nil
CellsBlip = 0
TimeBlip = 0
ShopBlip = 0
local insidecanteen = false
local insidefreedom = false
local canteen_ped = 0
local freedom_ped = 0
local freedom
local canteen

-- Functions

--- This will create the blips for the cells, time check and shop
local function CreateCellsBlip()
	if DoesBlipExist(CellsBlip) then
		RemoveBlip(CellsBlip)
	end

	CellsBlip = AddBlipForCoord(Config.Locations["yard"].coords.x, Config.Locations["yard"].coords.y, Config.Locations["yard"].coords.z)

	SetBlipSprite (CellsBlip, 238)
	SetBlipDisplay(CellsBlip, 4)
	SetBlipScale  (CellsBlip, 0.8)
	SetBlipAsShortRange(CellsBlip, true)
	SetBlipColour(CellsBlip, 4)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(Lang:t("info.cells_blip"))
	EndTextCommandSetBlipName(CellsBlip)

	if DoesBlipExist(TimeBlip) then
		RemoveBlip(TimeBlip)
	end

	TimeBlip = AddBlipForCoord(Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z)

	SetBlipSprite(TimeBlip, 466)
	SetBlipDisplay(TimeBlip, 4)
	SetBlipScale(TimeBlip, 0.8)
	SetBlipAsShortRange(TimeBlip, true)
	SetBlipColour(TimeBlip, 4)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(Lang:t("info.freedom_blip"))
	EndTextCommandSetBlipName(TimeBlip)

	if DoesBlipExist(ShopBlip) then
		RemoveBlip(ShopBlip)
	end

	ShopBlip = AddBlipForCoord(Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z)

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
	local playerPed = cache.ped
	if DoesEntityExist(playerPed) then
		Citizen.CreateThread(function()
			SetPedArmour(playerPed, 0)
			ClearPedBloodDamage(playerPed)
			ResetPedVisibleDamage(playerPed)
			ClearPedLastWeaponDamage(playerPed)
			ResetPedMovementClipset(playerPed, 0)
			if QBX.PlayerData.charinfo.gender == 0 then
				TriggerEvent('qb-clothing:client:loadOutfit', Config.Uniforms.male)
			else
				TriggerEvent('qb-clothing:client:loadOutfit', Config.Uniforms.female)
			end
		end)
	end
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	if QBX.PlayerData.metadata.injail > 0 then
		TriggerEvent("prison:client:Enter", QBX.PlayerData.metadata.injail)
	end

	lib.callback('prison:server:IsAlarmActive', false, function(active)
		if not active then return end
		TriggerEvent('prison:client:JailAlarm', true)
	end)

	if DoesEntityExist(canteen_ped) or DoesEntityExist(freedom_ped) then return end

	local pedModel = `s_m_m_armoured_01`
	lib.requestModel(pedModel)

	freedom_ped = CreatePed(0, pedModel, Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z, Config.Locations["freedom"].coords.w, false, true)
	FreezeEntityPosition(freedom_ped, true)
	SetEntityInvincible(freedom_ped, true)
	SetBlockingOfNonTemporaryEvents(freedom_ped, true)
	TaskStartScenarioInPlace(freedom_ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)

	canteen_ped = CreatePed(0, pedModel, Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z, Config.Locations["shop"].coords.w, false, true)
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
		distance = 2.5,
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
		distance = 2.5,
	})
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
	Wait(100)
	if LocalPlayer.state.isLoggedIn then
		if QBX.PlayerData.metadata.injail > 0 then
			TriggerEvent("prison:client:Enter", QBX.PlayerData.metadata.injail)
		end
	end

	lib.callback('prison:server:IsAlarmActive', false, function(active)
		if not active then return end
		TriggerEvent('prison:client:JailAlarm', true)
	end)

	if DoesEntityExist(canteen_ped) or DoesEntityExist(freedom_ped) then return end

	local pedModel = `s_m_m_armoured_01`
	lib.requestModel(pedModel)

	freedom_ped = CreatePed(0, pedModel, Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z, Config.Locations["freedom"].coords.w, false, true)
	FreezeEntityPosition(freedom_ped, true)
	SetEntityInvincible(freedom_ped, true)
	SetBlockingOfNonTemporaryEvents(freedom_ped, true)
	TaskStartScenarioInPlace(freedom_ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)

	canteen_ped = CreatePed(0, pedModel, Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z, Config.Locations["shop"].coords.w, false, true)
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
		distance = 2.5,
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
		distance = 2.5,
	})
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
	inJail = false
	currentJob = nil
	RemoveBlip(currentBlip)
end)

--- TODO: make this an export
AddEventHandler('prison:client:Enter', function(time)
	exports.qbx_core:Notify( Lang:t("error.injail", {Time = time}), "error")

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
	SetEntityCoords(cache.ped, RandomStartPosition.coords.x, RandomStartPosition.coords.y, RandomStartPosition.coords.z - 0.9, false, false, false, false)
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
	exports.qbx_core:Notify( Lang:t("error.do_some_work", {currentjob = Config.Jobs[currentJob] }), "error")
end)

RegisterNetEvent('prison:client:Leave', function()
	if jailTime > 0 then
		exports.qbx_core:Notify( Lang:t("info.timeleft", {JAILTIME = jailTime}))
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
		RemoveBlip(TimeBlip)
		TimeBlip = nil
		RemoveBlip(ShopBlip)
		ShopBlip = nil
		exports.qbx_core:Notify(Lang:t("success.free_"))
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Wait(10)
		end
		TriggerServerEvent('qb-clothes:loadPlayerSkin')
		SetEntityCoords(cache.ped, Config.Locations["outside"].coords.x, Config.Locations["outside"].coords.y, Config.Locations["outside"].coords.z, false, false, false, false)
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
		RemoveBlip(TimeBlip)
		RemoveBlip(ShopBlip)
		exports.qbx_core:Notify(Lang:t("success.free_"))
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Wait(10)
		end
		TriggerServerEvent('qb-clothes:loadPlayerSkin')
		SetEntityCoords(cache.ped, Config.Locations["outside"].coords.x, Config.Locations["outside"].coords.y, Config.Locations["outside"].coords.z, false, false, false, false)
		SetEntityHeading(cache.ped, Config.Locations["outside"].coords.w)
		Wait(500)
		DoScreenFadeIn(1000)
	end
end)

RegisterNetEvent('prison:client:canteen',function()
	local ShopItems = {}
	ShopItems.label = "Prison Canteen"
	ShopItems.items = Config.CanteenItems
	ShopItems.slots = #Config.CanteenItems
	TriggerServerEvent("inventory:server:OpenInventory", "shop", "Canteenshop_"..math.random(1, 99), ShopItems)
end)

-- Threads

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
					exports.qbx_core:Notify(Lang:t("success.timesup"), "success", 10000)
				end
				TriggerServerEvent("prison:server:SetJailStatus", jailTime)
			end
		end
		Wait(sleep)
	end
end)

CreateThread(function()
	if not Config.UseTarget then
		freedom = BoxZone:Create(vector3(Config.Locations["freedom"].coords.x, Config.Locations["freedom"].coords.y, Config.Locations["freedom"].coords.z), 2.75, 2.75, {
			name="freedom",
			debugPoly = false,
		})
		freedom:onPlayerInOut(function(isPointInside)
			insidefreedom = isPointInside
			if isPointInside then
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
				lib.showTextUI('[E] Check Time')
			else
				lib.hideTextUI()
			end
		end)
		canteen = BoxZone:Create(vector3(Config.Locations["shop"].coords.x, Config.Locations["shop"].coords.y, Config.Locations["shop"].coords.z), 2.75, 7.75, {
			name="canteen",
			debugPoly = false,
		})
		canteen:onPlayerInOut(function(isPointInside)
			insidecanteen = isPointInside
			if isPointInside then
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
				lib.showTextUI('[E] Open Canteen')
			else
				lib.hideTextUI()
			end
		end)
	end
end)
