InJail = false
JailTime = 0
CurrentJob = nil
CellsBlip = 0
TimeBlip = 0
ShopBlip = 0
local canteenPed = 0
local freedomPed = 0

-- Functions

--- This will create the blips for the cells, time check and shop
local function createCellsBlip()
	if DoesBlipExist(CellsBlip) then
		RemoveBlip(CellsBlip)
	end

	CellsBlip = AddBlipForCoord(Config.Locations.yard.coords.x, Config.Locations.yard.coords.y, Config.Locations.yard.coords.z)

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

	TimeBlip = AddBlipForCoord(Config.Locations.freedom.coords.x, Config.Locations.freedom.coords.y, Config.Locations.freedom.coords.z)

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

	ShopBlip = AddBlipForCoord(Config.Locations.shop.coords.x, Config.Locations.shop.coords.y, Config.Locations.shop.coords.z)

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

local function applyClothes()
	local playerPed = cache.ped
	if not DoesEntityExist(playerPed) then return end
	CreateThread(function()
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

local function turnOnAlarmIfActive()
	lib.callback('prison:server:IsAlarmActive', false, function(active)
		if not active then return end
		TriggerEvent('prison:client:JailAlarm', true)
	end)
end

local function release()
	JailTime = 0
	InJail = false
	RemoveBlip(CurrentBlip)
	RemoveBlip(CellsBlip)
	RemoveBlip(TimeBlip)
	RemoveBlip(ShopBlip)
	exports.qbx_core:Notify(Lang:t("success.free_"))
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end
	TriggerServerEvent('qb-clothes:loadPlayerSkin')
	SetEntityCoords(cache.ped, Config.Locations.outside.coords.x, Config.Locations.outside.coords.y, Config.Locations.outside.coords.z, false, false, false, false)
	SetEntityHeading(cache.ped, Config.Locations.outside.coords.w)

	Wait(500)
	DoScreenFadeIn(1000)
end

local function askToLeave()
	if JailTime > 0 then
		exports.qbx_core:Notify( Lang:t("info.timeleft", {JAILTIME = JailTime}))
	else
		release()
	end
end

local function openCanteen()
	exports.ox_inventory:openInventory('shop', { type = 'Canteen', id = 1})
end

--- TODO: switch to ox_target
local function spawnNPCsIfNotExisting()
	if DoesEntityExist(canteenPed) or DoesEntityExist(freedomPed) then return end

	local pedModel = `s_m_m_armoured_01`
	lib.requestModel(pedModel)

	freedomPed = CreatePed(0, pedModel, Config.Locations.freedom.coords.x, Config.Locations.freedom.coords.y, Config.Locations.freedom.coords.z, Config.Locations.freedom.coords.w, false, true)
	FreezeEntityPosition(freedomPed, true)
	SetEntityInvincible(freedomPed, true)
	SetBlockingOfNonTemporaryEvents(freedomPed, true)
	TaskStartScenarioInPlace(freedomPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)

	canteenPed = CreatePed(0, pedModel, Config.Locations.shop.coords.x, Config.Locations.shop.coords.y, Config.Locations.shop.coords.z, Config.Locations.shop.coords.w, false, true)
	FreezeEntityPosition(canteenPed, true)
	SetEntityInvincible(canteenPed, true)
	SetBlockingOfNonTemporaryEvents(canteenPed, true)
	TaskStartScenarioInPlace(canteenPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)

	if not Config.UseTarget then return end

	exports.ox_target:addLocalEntity(freedomPed, {
		{
			icon = 'fas fa-clipboard',
			label = Lang:t("info.target_freedom_option"),
			canInteract = function()
				return InJail
			end,
			onSelect = askToLeave
		}
	})

	exports.ox_target:addLocalEntity(canteenPed, {
		{
			icon = 'fas fa-clipboard',
			label = Lang:t("info.target_canteen_option"),
			canInteract = function()
				return InJail
			end,
			onSelect = openCanteen
		}
	})
end

local function initPrison(time)
	InJail = true
	JailTime = time
	CurrentJob = "Electrician"
	CreateJobBlip()
	applyClothes()
	createCellsBlip()
	TriggerServerEvent("InteractSound_SV:PlayOnSource", "jail", 0.5)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	if QBX.PlayerData.metadata.injail > 0 then
		initPrison(QBX.PlayerData.metadata.injail)
	end

	turnOnAlarmIfActive()
	spawnNPCsIfNotExisting()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
	Wait(100)
	if LocalPlayer.state.isLoggedIn then
		if QBX.PlayerData.metadata.injail > 0 then
			initPrison(QBX.PlayerData.metadata.injail)
		end
	end

	turnOnAlarmIfActive()
	spawnNPCsIfNotExisting()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
	InJail = false
	CurrentJob = nil
	RemoveBlip(CurrentBlip)
end)

local function onEnter(minutes)
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end
	local randomStartPosition = Config.Locations.spawns[math.random(1, #Config.Locations.spawns)]
	SetEntityCoords(cache.ped, randomStartPosition.coords.x, randomStartPosition.coords.y, randomStartPosition.coords.z - 0.9, false, false, false, false)
	SetEntityHeading(cache.ped, randomStartPosition.coords.w)
	Wait(500)
	TriggerEvent('animations:client:EmoteCommandStart', {randomStartPosition.animation})
	initPrison(minutes)
	Wait(2000)
	DoScreenFadeIn(1000)
	exports.qbx_core:Notify( Lang:t("error.do_some_work", {currentjob = 'Electrician' }), "error")
end

RegisterNetEvent('qbx_prison:client:playerJailed', function(minutes)
	if GetInvokingResource() then return end
	onEnter(minutes)
end)

RegisterNetEvent('qbx_prison:client:playerReleased', function()
	if GetInvokingResource() then return end
	release()
end)

-- Threads

CreateThread(function()
    TriggerEvent('prison:client:JailAlarm', false)
	while true do
		local sleep = 1000
		if JailTime > 0 and InJail then
			Wait(1000 * 60)
			sleep = 0
			if JailTime > 0 and InJail then
				JailTime -= 1
				if JailTime <= 0 then
					JailTime = 0
					exports.qbx_core:Notify(Lang:t("success.timesup"), "success", 10000)
				end
				TriggerServerEvent("prison:server:SetJailStatus", JailTime)
			end
		end
		Wait(sleep)
	end
end)

if not Config.UseTarget then

	local function listenForKeyPressToLeave()
		if IsControlJustReleased(0, 38) then
			lib.hideTextUI()
			askToLeave()
		end
	end

	local function listenForKeyPressToOpenCanteen()
		if IsControlJustReleased(0, 38) then
			lib.hideTextUI()
			openCanteen()
		end
	end

	CreateThread(function()
		lib.zones.sphere({
			coords = Config.Locations.freedom.coords.xyz,
			radius = 2.75,
			onEnter = function()
				lib.showTextUI('[E] Check Time')
			end,
			onExit = function()
				lib.hideTextUI()
			end,
			inside = listenForKeyPressToLeave,
		})
		lib.zones.sphere({
			coords = Config.Locations.shop.coords.xyz,
			radius = 2.75,
			onEnter = function()
				lib.showTextUI('[E] Open Canteen')
			end,
			onExit = function()
				lib.hideTextUI()
			end,
			inside = listenForKeyPressToOpenCanteen,
		})
	end)
end

---@deprecated call server export JailPlayer instead
AddEventHandler('prison:client:Enter', function()
	lib.print.error(GetInvokingResource(), "invoked deprecated event prison:client:Enter. Call server export JailPlayer instead.")
end)

---@deprecated call server export ReleasePlayer instead
RegisterNetEvent('prison:client:UnjailPerson', function()
	lib.print.error(GetInvokingResource(), "invoked deprecated prison:client:UnjailPerson event. Call server export ReleasePlayer instead.")
end)

---@deprecated do not call.
AddEventHandler('prison:client:Leave', function()
	lib.print.error(GetInvokingResource(), "invoked deprecated prison:client:Leave event. No action taken.")
end)

---@deprecated do not call.
RegisterNetEvent('prison:client:canteen', function()
	lib.print.error(GetInvokingResource(), "invoked deprecated prison:client:canteen event. No action taken.")
end)