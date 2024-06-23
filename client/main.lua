InJail = false
JailTime = 0
CurrentJob = nil
CellsBlip = 0
TimeBlip = 0
ShopBlip = 0
local canteenPed = 0
local freedomPed = 0
local config = require('config.shared')

-- Functions

--- This will create the blips for the cells, time check and shop
local function createCellsBlip()
	if DoesBlipExist(CellsBlip) then
		RemoveBlip(CellsBlip)
	end

	CellsBlip = AddBlipForCoord(config.locations.yard.coords.x, config.locations.yard.coords.y, config.locations.yard.coords.z)

	SetBlipSprite (CellsBlip, 238)
	SetBlipDisplay(CellsBlip, 4)
	SetBlipScale  (CellsBlip, 0.8)
	SetBlipAsShortRange(CellsBlip, true)
	SetBlipColour(CellsBlip, 4)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(locale("info.cells_blip"))
	EndTextCommandSetBlipName(CellsBlip)

	if DoesBlipExist(TimeBlip) then
		RemoveBlip(TimeBlip)
	end

	TimeBlip = AddBlipForCoord(config.locations.freedom.coords.x, config.locations.freedom.coords.y, config.locations.freedom.coords.z)

	SetBlipSprite(TimeBlip, 466)
	SetBlipDisplay(TimeBlip, 4)
	SetBlipScale(TimeBlip, 0.8)
	SetBlipAsShortRange(TimeBlip, true)
	SetBlipColour(TimeBlip, 4)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(locale("info.freedom_blip"))
	EndTextCommandSetBlipName(TimeBlip)

	if DoesBlipExist(ShopBlip) then
		RemoveBlip(ShopBlip)
	end

	ShopBlip = AddBlipForCoord(config.locations.shop.coords.x, config.locations.shop.coords.y, config.locations.shop.coords.z)

	SetBlipSprite(ShopBlip, 52)
	SetBlipDisplay(ShopBlip, 4)
	SetBlipScale(ShopBlip, 0.5)
	SetBlipAsShortRange(ShopBlip, true)
	SetBlipColour(ShopBlip, 0)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(locale("info.canteen_blip"))
	EndTextCommandSetBlipName(ShopBlip)
end

local function createPrisonBlip()
	if not next(config.locations.prison) then return end
	for _, station in pairs(config.locations.prison) do
		local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
		SetBlipSprite(blip, 188)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, 42)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(station.label)
		EndTextCommandSetBlipName(blip)
	end
end

-- Add clothes to prisioner

local function applyClothes()
	if not DoesEntityExist(cache.ped) then return end
	CreateThread(function()
		SetPedArmour(cache.ped, 0)
		ClearPedBloodDamage(cache.ped)
		ResetPedVisibleDamage(cache.ped)
		ClearPedLastWeaponDamage(cache.ped)
		ResetPedMovementClipset(cache.ped, 0)
		if QBX.PlayerData.charinfo.gender == 0 then
			TriggerEvent('qb-clothing:client:loadOutfit', config.uniforms.male)
		else
			TriggerEvent('qb-clothing:client:loadOutfit', config.uniforms.female)
		end
	end)
end

local function turnOnAlarmIfActive()
	lib.callback('prison:server:IsAlarmActive', false, function(active)
		if not active then return end
		TriggerEvent('prison:client:JailAlarm', true)
	end)
end

local function takePhoto()
    DoScreenFadeOut(10)
    FreezeEntityPosition(cache.ped, true)
    SetPedComponentVariation(cache.ped, 1, -1, -1, -1)
    ClearPedProp(cache.ped, 0)
    Wait(1000)
    SetEntityCoords(cache.ped, config.locations.takePhoto.coords.x, config.locations.takePhoto.coords.y, config.locations.takePhoto.coords.z)
    SetEntityHeading(cache.ped, 270.0)
    Wait(1500)
    DoScreenFadeIn(500)
    qbx.playAudio({ audioName = 'Camera_Shoot', audioRef = 'Phone_Soundset_Franklin' })
    Wait(3000)
    qbx.playAudio({ audioName = 'Camera_Shoot', audioRef = 'Phone_Soundset_Franklin' })
    Wait(3000)
    SetEntityHeading(cache.ped, -355.74)
    qbx.playAudio({ audioName = 'Camera_Shoot', audioRef = 'Phone_Soundset_Franklin' })
    Wait(3000)
    qbx.playAudio({ audioName = 'Camera_Shoot', audioRef = 'Phone_Soundset_Franklin' })
    Wait(3000)
    SetEntityHeading(cache.ped, 170.74)
    qbx.playAudio({ audioName = 'Camera_Shoot', audioRef = 'Phone_Soundset_Franklin' })
    Wait(3000)
    qbx.playAudio({ audioName = 'Camera_Shoot', audioRef = 'Phone_Soundset_Franklin' })
    Wait(3000)
    SetEntityHeading(cache.ped, 270.0)
    Wait(2000)
    DoScreenFadeOut(1100)
    Wait(2000)
end

local function release()
	JailTime = 0
	InJail = false
	RemoveBlip(CurrentBlip)
	RemoveBlip(CellsBlip)
	RemoveBlip(TimeBlip)
	RemoveBlip(ShopBlip)
	exports.qbx_core:Notify(locale("success.free_"))
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end
	TriggerServerEvent('qb-clothes:loadPlayerSkin')
	SetEntityCoords(cache.ped, config.locations.outside.coords.x, config.locations.outside.coords.y, config.locations.outside.coords.z, false, false, false, false)
	SetEntityHeading(cache.ped, config.locations.outside.coords.w)

	Wait(500)
	DoScreenFadeIn(1000)
end

local function askToLeave()
	if JailTime > 0 then
		exports.qbx_core:Notify( locale("info.timeleft", JailTime))
	else
		TriggerServerEvent('qbx_prison:server:playerAsksToLeave')
	end
end

local function openCanteen()
	exports.ox_inventory:openInventory('shop', { type = 'Canteen', id = 1})
end

local function pedCreate(pedModel, position, scenario)
    lib.requestModel(pedModel, 10000)
    local entity = CreatePed(0, pedModel, position.x, position.y, position.z, position.w, false, true)

    if scenario then
        TaskStartScenarioInPlace(entity, scenario, 0, true)
    end

    SetModelAsNoLongerNeeded(pedModel)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)

    return entity
end

local function spawnNPCsIfNotExisting()
	if DoesEntityExist(canteenPed) or DoesEntityExist(freedomPed) then return end

	freedomPed = pedCreate('s_m_m_armoured_01', config.locations.freedom.coords, 'WORLD_HUMAN_CLIPBOARD')
	canteenPed = pedCreate('s_m_m_armoured_01', config.locations.shop.coords, 'WORLD_HUMAN_CLIPBOARD')

	if not config.useTarget then return end

	exports.ox_target:addLocalEntity(freedomPed, {
		{
			icon = 'fas fa-clipboard',
			label = locale("info.target_freedom_option"),
			canInteract = function()
				return InJail
			end,
			onSelect = askToLeave
		}
	})

	exports.ox_target:addLocalEntity(canteenPed, {
		{
			icon = 'fas fa-clipboard',
			label = locale("info.target_canteen_option"),
			canInteract = function()
				return InJail
			end,
			onSelect = openCanteen
		}
	})
end

local function initPrison(time)
    if config.takePhoto then
        takePhoto()
    end
    FreezeEntityPosition(cache.ped, false)
	InJail = true
	JailTime = time
	CurrentJob = "Electrician"
	CreateJobBlip()
	applyClothes()
	createCellsBlip()
	exports.qbx_core:Notify(config.introMessages[math.random(1, #config.introMessages)], "inform", 10000)
	TriggerServerEvent("InteractSound_SV:PlayOnSource", "jail", 0.5)

	CreateThread(function()
		while JailTime > 0 and InJail do
			Wait(60000)
			if JailTime > 0 and InJail then
				JailTime -= 1
				if JailTime <= 0 then
					JailTime = 0
					exports.qbx_core:Notify(locale("success.timesup"), "success", 10000)
				end
				TriggerServerEvent("prison:server:SetJailStatus", JailTime)
			end
		end
	end)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	if QBX.PlayerData.metadata.injail > 0 then
		initPrison(QBX.PlayerData.metadata.injail)
	end

	createPrisonBlip()
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
	local randomStartPosition = config.locations.spawns[math.random(1, #config.locations.spawns)]
	SetEntityCoords(cache.ped, randomStartPosition.coords.x, randomStartPosition.coords.y, randomStartPosition.coords.z - 0.9, false, false, false, false)
	SetEntityHeading(cache.ped, randomStartPosition.coords.w)
	Wait(500)
	TriggerEvent('animations:client:EmoteCommandStart', {randomStartPosition.animation})
	initPrison(minutes)
	Wait(2000)
	DoScreenFadeIn(1000)
	exports.qbx_core:Notify( locale("error.do_some_work", "Electrician"), "error")
end

RegisterNetEvent('qbx_prison:client:playerJailed', function(minutes)
	if GetInvokingResource() then return end
	onEnter(minutes)
end)

RegisterNetEvent('qbx_prison:client:playerReleased', function()
	if GetInvokingResource() then return end
	release()
end)

if not config.useTarget then

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
			coords = config.locations.freedom.coords.xyz,
			radius = 2.75,
			onEnter = function()
				lib.showTextUI(locale('info.check_time'))
			end,
			onExit = function()
				lib.hideTextUI()
			end,
			inside = listenForKeyPressToLeave,
		})
		lib.zones.sphere({
			coords = config.locations.shop.coords.xyz,
			radius = 2.75,
			onEnter = function()
				lib.showTextUI(locale('info.open_canteen'))
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
