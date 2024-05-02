CurrentBlip = 0
local isWorking = false
local config = require('config.shared')

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

local electricalBoxes = newRandomArray(#config.jobs.electrician.locations)
local currentBox = 1

--- This will create the blip for the current prison job
function CreateJobBlip() -- Used globally
    if DoesBlipExist(CurrentBlip) then
        RemoveBlip(CurrentBlip)
    end

    local coords = config.jobs.electrician.locations[currentBox]
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

--- This will set the job as done and give a new location at the same time for you to continue the job and give you some time cut as a reward
local function onBoxDone()
    if math.random(1, 100) <= 50 then
        exports.qbx_core:Notify(locale("success.time_cut"))
        JailTime -= math.random(1, 2)
    end

    if currentBox == #electricalBoxes then
        electricalBoxes = newRandomArray(#config.jobs.electrician.locations)
        currentBox = 1
        TriggerServerEvent('qbx_prison:server:completedJob')
    else
        currentBox += 1
    end

    CreateJobBlip()
end

--- This will be triggered once you interact with a job location to perform your job at
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
        onBoxDone()
    else
        exports.qbx_core:Notify(locale("error.cancelled"), "error")
    end

    isWorking = false
    StopAnimTask(cache.ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
end

local function canInteractWithBox(i)
    return InJail and CurrentJob and not isWorking and i == currentBox
end

-- Threads
CreateThread(function()
    for i = 1, #config.jobs.electrician.locations do
        local coords = config.jobs.electrician.locations[i]
        if config.useTarget then
            exports.ox_target:addBoxZone({
                coords = coords,
                size = vec3(1.5, 1.6, 5),
                options = {
                    {
                        icon = 'fa-solid fa-bolt',
                        label = locale("info.job_interaction_target", "Electrician"),
                        canInteract = function()
                            return canInteractWithBox(i)
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
                    lib.showTextUI(locale("info.job_interaction"))
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = function()
                    if not canInteractWithBox(i) then return end
                    if IsControlJustReleased(0, 38) then
                        startWork()
                    end
                end,
            })
        end
    end
end)
