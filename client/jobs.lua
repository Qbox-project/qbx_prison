local prisonJob = nil
local CurrentBlip = 0
local isWorking = false
local jobLocations
local currentTask = 1

local function newRandomArray(size)
    local array = {}
    for i = 1, size do
        array[i] = i
    end
    for i = size, 2, -1 do
        local rand = math.random(size)
        array[i], array[rand] = array[rand], array[i]
    end
    return array
end

local function CreateJobBlip()
    if DoesBlipExist(CurrentBlip) then
        RemoveBlip(CurrentBlip)
    end

    local coords = Config.Jobs[prisonJob].locations[currentTask]
    CurrentBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(CurrentBlip, 402)
    SetBlipDisplay(CurrentBlip, 4)
    SetBlipScale(CurrentBlip, 0.8)
    SetBlipAsShortRange(CurrentBlip, true)
    SetBlipColour(CurrentBlip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(locale("info.work_blip"))
    EndTextCommandSetBlipName(CurrentBlip)
end

local function onTaskDone()
    if math.random(1, 100) <= 50 then
        exports.qbx_core:Notify(locale("success.time_cut"))
        JailTime -= math.random(1, 2)
    end

    if currentTask == #jobLocations then
        jobLocations = newRandomArray(#Config.Jobs[prisonJob].locations)
        currentTask = 1
        TriggerServerEvent('qbx_prison:server:completedJob')
    else
        currentTask += 1
    end

    CreateJobBlip()
end

local function startWork()
    isWorking = true
    if lib.progressBar({
        duration = math.random(5000, 10000),
        label = locale("info.working_electricity"),
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
        onTaskDone()
    else
        exports.qbx_core:Notify(locale("error.cancelled"), "error")
    end

    isWorking = false
    StopAnimTask(cache.ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
end

local function canInteractWithTask(i)
    return InJail and prisonJob and not isWorking and i == currentTask
end

function chooseJob(job)
    prisonJob = job
    jobLocations = newRandomArray(#Config.Jobs[prisonJob].locations)
end

exports('getPrisonJob', function()
    return prisonJob
end)

CreateThread(function()
    if prisonJob then
        for i = 1, #Config.Jobs[prisonJob].locations do
            local coords = Config.Jobs[prisonJob].locations[i]
            if Config.UseTarget then
                exports.ox_target:addBoxZone({
                    coords = coords,
                    size = vec3(1.5, 1.6, 5),
                    options = {
                        {
                            icon = 'fa-solid fa-bolt',
                            label = locale("info.job_interaction_target", prisonJob),
                            canInteract = function()
                                return canInteractWithTask(i)
                            end,
                            onSelect = startWork
                        }
                    }
                })
            else
                lib.zones.box({
                    coords = coords,
                    size = vec3(3, 5, 3),
                    onEnter = function()
                        lib.showTextUI(locale("info.job_interaction", prisonJob))
                    end,
                    onExit = function()
                        lib.hideTextUI()
                    end,
                    inside = function()
                        if not canInteractWithTask(i) then return end
                        if IsControlJustReleased(0, 38) then
                            startWork()
                        end
                    end,
                })
            end
        end
    end
end)
