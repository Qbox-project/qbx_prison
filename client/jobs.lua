local currentLocation = 1
CurrentBlip = 0
local isWorking = false

-- Functions

--- This will create the blip for the current prison job and give a reward if they were done with the previous one
--- @param noItem boolean | nil
function CreateJobBlip(noItem) -- Used globally
    if DoesBlipExist(CurrentBlip) then
        RemoveBlip(CurrentBlip)
    end

    local coords = Config.Locations.jobs[CurrentJob][currentLocation].coords.xyz
    CurrentBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(CurrentBlip, 402)
    SetBlipDisplay(CurrentBlip, 4)
    SetBlipScale(CurrentBlip, 0.8)
    SetBlipAsShortRange(CurrentBlip, true)
    SetBlipColour(CurrentBlip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Lang:t("info.work_blip"))
    EndTextCommandSetBlipName(CurrentBlip)
    if noItem then return end
    TriggerServerEvent('prison:server:CheckChance')
end

--- This will check all job locations of the current job to check if they're done or not
--- @return boolean
local function checkAllLocations()
    local amount = 0
    for i = 1, #Config.Locations.jobs[CurrentJob] do
        local current = Config.Locations.jobs[CurrentJob][i]
        if current.done then
            amount += 1
        end
    end
    return amount == #Config.Locations.jobs[CurrentJob]
end

--- This will reset all location of the current job
local function resetLocations()
    for i = 1, #Config.Locations.jobs[CurrentJob] do
        Config.Locations.jobs[CurrentJob][i].done = false
    end
end

--- This will set the job as done and give a new location at the same time for you to continue the job and give you some time cut as a reward
local function jobDone()
    if not Config.Locations.jobs[CurrentJob][currentLocation].done then return end
    if math.random(1, 100) <= 50 then
        exports.qbx_core:Notify(Lang:t("success.time_cut"))
        JailTime -= math.random(1, 2)
    end
    if checkAllLocations() then resetLocations() end
    local newLocation = math.random(1, #Config.Locations.jobs[CurrentJob])
    while newLocation == currentLocation or Config.Locations.jobs[CurrentJob][newLocation].done do
        Wait(0)
        newLocation = math.random(1, #Config.Locations.jobs[CurrentJob])
    end
    currentLocation = newLocation
    CreateJobBlip()
end

--- This will be triggered once you interact with a job location to perform your job at
local function startWork()
    isWorking = true
    Config.Locations.jobs[CurrentJob][currentLocation].done = true
    if lib.progressBar({
        duration = math.random(5000, 10000),
        label = Lang:t("info.working_electricity"),
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
        jobDone()
    else
        exports.qbx_core:Notify(Lang:t("error.cancelled"), "error")
    end

    isWorking = false
    StopAnimTask(cache.ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
end

-- Threads

CreateThread(function()
    local isInside = false
    for k in pairs(Config.Locations.jobs) do
        for i = 1, #Config.Locations.jobs[k] do
            local current = Config.Locations.jobs[k][i]
            if Config.UseTarget then
                exports.ox_target:addBoxZone({
                    coords = current.coords.xyz,
                    size = vec3(1.5, 1.6, 5),
                    options = {
                        {
                            icon = 'fa-solid fa-bolt',
                            label = Lang:t("info.job_interaction_target", {job = Config.Jobs[k]}),
                            canInteract = function()
                                return InJail and CurrentJob and not Config.Locations.jobs[k][i].done and not isWorking and i == currentLocation
                            end,
                            onSelect = startWork
                        }
                    }
                })
            else
                local electricityzone = BoxZone:Create(current.coords.xyz, 3.0, 5.0, {
                    name = "work_"..k.."_"..i,
                    debugPoly = false,
                })
                electricityzone:onPlayerInOut(function(isPointInside)
                    isInside = isPointInside and InJail and CurrentJob and not Config.Locations.jobs[k][i].done and not isWorking
                    if isInside then
                        lib.showTextUI(Lang:t("info.job_interaction"))
                    else
                        lib.hideTextUI()
                    end
                end)
            end
            Config.Locations.jobs[k][i].done = false
        end
    end
    if not Config.UseTarget then
        while true do
            local sleep = 1000
            if isInside then
                sleep = 0
                if IsControlJustReleased(0, 38) then
                    startWork()
                    sleep = 1000
                end
            end
            Wait(sleep)
        end
    end
end)
