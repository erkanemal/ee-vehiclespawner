
local function Notify(msg)
    SetTextFont(1)
    SetNotificationTextEntry('STRING')
    AddTextComponentSubstringPlayerName(msg)
    DrawNotification(false, true)
end

local busy = false

local function SpawnVehicle(modelName)
    if busy then
        Notify('Please wait until the vehicle is spawned.')
        return
    end

    local lastvehicle = cache.vehicle
    local lastvehiclecoords = GetOffsetFromEntityInWorldCoords(cache.vehicle, 3.0, 0.0, 0.5)

    local pPed = PlayerPedId()
    local coords = GetEntityCoords(pPed)


    if cache.vehicle then
        if GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped then
            DeleteVehicle(cache.vehicle)
        else
            coords = lastvehiclecoords
        end
    end

    local modelHash = GetHashKey(modelName)

    busy = true

    if IsModelInCdimage(modelHash) then
        lib.requestModel(modelName, 20000)
    else
        Notify('Vehicle model not found.')
        busy = false
        return
    end

    if not HasModelLoaded(modelHash) then
        busy = false
        Notify('Vehicle model failed to load.')
        return
    end
    
    local heading = GetEntityHeading(pPed)
    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)

    local timer = 0
    while not DoesEntityExist(vehicle) do
        Wait(0)
        timer = timer + 1
        if timer > 5000 then
            Notify('Vehicle took too long to spawn, please try again.')
            busy = false
            return
        end
    end
    busy = false
    SetModelAsNoLongerNeeded(modelHash) 
    SetEntityAsMissionEntity(vehicle)
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAlpha(vehicle, 0, false)
    TaskWarpPedIntoVehicle(pPed, vehicle, -1)
    NetworkFadeInEntity(vehicle, true, true)
    PlaySoundFromEntity(-1, "Remote_Control_Fob", vehicle, "PI_Menu_Sounds", 1, 0)
    SetVehicleLights(vehicle ,0)
    Wait(200)
    PlaySoundFromEntity(-1, "Remote_Control_Fob", vehicle, "PI_Menu_Sounds", 1, 0)
end




CreateThread(function()
    local options = {}
    for i = 1, #Config.menus do
        local icon = Config.menus[i].icon or 'dollar-sign'
        table.insert(options, {label = Config.menus[i].name, icon = icon})

        local values = {}
        for j = 1, #Config.menus[i].vehicles do
            table.insert(values, {close = false, label = Config.menus[i].vehicles[j].name, args = {Config.menus[i].vehicles[j].spawncode}})
        end

        lib.registerMenu({
            id = Config.menus[i].name,
            title = Config.menus[i].name,
            position = 'top-right',
            onSideScroll = function(selected, scrollIndex, args)
    
            end,
            onSelected = function(selected, secondary, args)
    
            end,
            onClose = function(keyPressed)
                lib.showMenu('spawner')
            end,
            options = values
        }, function(selected, scrollIndex, args)
            SpawnVehicle(args[1])
        end)
    end

    lib.registerMenu({
        id = 'spawner',
        title = 'Vehicle Spawner',
        position = 'top-right',
        onSideScroll = function(selected, scrollIndex, args)

        end,
        onSelected = function(selected, secondary, args)

        end,

        options = options
    }, function(selected, scrollIndex, args)
        print(selected, scrollIndex, args)
        local name = options[selected]
        print(json.encode(name))
        lib.showMenu(options[selected].label)
    end)
    
end)



-- CreateThread(function()
--     Wait(1000)
--     for i = 1, #Config.menus do
--         Config.menus[i].menu =  MenuV:CreateMenu(false, Config.menus[i].name, 'topright', 129, 0, 255, 'size-175', 'psrp', 'psrp', Config.menus[i].name)
--         local m = Config.menus[i].menu
--         local vehicles = Config.menus[i].vehicles
--         for j = 1, #vehicles do
--             m:AddButton({ icon = '', label = vehicles[j].name, value = vehicles[j].spawncode, description = 'Spawn ' .. vehicles[j].name, select = function(btn) SpawnVehicle(btn.Value) end })
--         end
--     end
--     Wait(1000)
--     for i = 1, #Config.menus do
--         local data = Config.menus[i]
--         menu:AddButton({ icon = '', label = data.name, value = data.menu, description = '', select = function(i) end })
--     end
-- end)

RegisterCommand('+spawner', function()
    lib.showMenu('spawner')
end)

RegisterKeyMapping('+spawner', 'Spawn vehicle', 'keyboard', 'F9')


