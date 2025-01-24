lib.locale()
local chosenVehicle = nil
local currentDelivery = nil
local pickupLocation = nil

CreateThread(function()
    if FS.depotlocation.blipEnabled then
        local blip = AddBlipForCoord(FS.depotlocation.x, FS.depotlocation.y, FS.depotlocation.z)
        SetBlipSprite(blip, 889)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(locale('food_delivery_depot'))
        EndTextCommandSetBlipName(blip)
    end
end)

local depotlocation = vector3(FS.depotlocation.x, FS.depotlocation.y, FS.depotlocation.z)
exports.ox_target:addSphereZone({
    coords = depotlocation,
    name = "depotlocation",
    radius = 3.0,
    debug = drawZones,
    drawSprite = true,
    options = {
        {
            event = "fs-fooddelivery:client:openDeliveryMenu",
            icon = "fas fa-utensils",
            label = locale('open_delivery_menu'),
        },
    },
})

local routeBlip
local function setRoute(x, y, title)
    routeBlip = AddBlipForCoord(x, y, 0)
    SetBlipSprite(routeBlip, 205)
    SetBlipDisplay(routeBlip, 4)
    SetBlipScale(routeBlip, 0.8)
    SetBlipColour(routeBlip, 2)
    SetBlipAsShortRange(routeBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(title)
    EndTextCommandSetBlipName(routeBlip)
    SetNewWaypoint(x, y)
end

local function deliverFood()
    if not chosenVehicle == nil then return end

    lib.hideTextUI()
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local dist = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, currentDelivery.x, currentDelivery.y, currentDelivery.z, true)

    RemoveBlip(routeBlip)
    if dist < 5.0 then
        if lib.progressBar({
            duration = 5000,
            label = locale('delivering_food'),
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
            },
            anim = {
                dict = "timetable@jimmy@doorknock@",
                name = "knockdoor_idle",
                clip = "knockdoor_idle",
            },
        }) then
            RemoveBlip(routeBlip)
            TriggerServerEvent("fs-fooddelivery:server:deliverFood", currentDelivery)
            chosenVehicle = nil
            currentDelivery = nil
            pickupLocation = nil
        else 
            RemoveBlip(routeBlip)
            chosenVehicle = nil
            currentDelivery = nil
            pickupLocation = nil
        end
        
    end
end

RegisterNetEvent('fs-fooddelivery:client:changeCurrent')
AddEventHandler('fs-fooddelivery:client:changeCurrent', function(index)
    for _,v in pairs(FS.deliveryPoints) do
        v.current = false
    end
end)

local function changeCurrent(index)
    for _,v in pairs(FS.deliveryPoints) do
        v.current = false
    end
    FS.deliveryPoints[index].current = true

    TriggerServerEvent('fs-fooddelivery:updateCurrent', index)
end

local function pickupFood(restaurant)
    if not restaurant then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local dist = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, restaurant.x, restaurant.y, restaurant.z, true)

    if dist < 5.0 then
        lib.hideTextUI()
        if lib.progressBar({
            duration = 5000,
            label = locale('picking_food'),
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
            },
            anim = {
                dict = "timetable@jimmy@doorknock@",
                name = "knockdoor_idle",
                clip = "knockdoor_idle",
            },
        }) then
            exports.ox_lib:notify({title = 'FS-fooddelivery', type = "info", description = locale('food_pickedup')})
            RemoveBlip(routeBlip)

            local rand = math.random(1, #FS.deliveryPoints)
            local delivery = FS.deliveryPoints[rand]
            changeCurrent(rand)
            currentDelivery = delivery
            setRoute(delivery.x, delivery.y, locale('delivery_address'))

            local deliverypoint = lib.points.new({
                id = "delivery",
                coords = vector3(delivery.x, delivery.y, delivery.z),
                distance = 3.0,
            })

            function deliverypoint:onEnter()
                lib.showTextUI("[E] - " .. locale('deliver'), {
                    icon = 'hand',
                    style = {
                        borderRadius = 25,
                    }
                })
            end

            function deliverypoint:onExit()
                lib.hideTextUI()
            end

            function deliverypoint:nearby()
                if self.currentDistance < 3.0 and IsControlJustReleased(0, 38) then
                    deliverFood()
                    deliverypoint:remove()
                end
            end

        else 
            RemoveBlip(routeBlip)
            chosenVehicle = nil
            currentDelivery = nil
            pickupLocation = nil
            exports.ox_lib:notify({title = 'FS-fooddelivery', type = "error", description = locale('pickup_failed')})
        end

    end

end

local function startPickup()
    local rand = math.random(1, #FS.restaurants)
    local pickup = FS.restaurants[rand]
    if not pickup then
        exports.ox_lib:notify({title = 'FS-fooddelivery', type = "error", description = locale('no_restaurant')})
        return
    end

    pickupLocation = pickup
    setRoute(pickup.x, pickup.y, pickup.name)
    exports.ox_lib:notify({title = 'FS-fooddelivery', type = "info", description = locale('pickup_location', pickup.name)})
    local respoint = lib.points.new({
        id = "restaurant",
        coords = vector3(pickup.x, pickup.y, pickup.z),
        distance = 3.0,
    })

    function respoint:onEnter()
        lib.showTextUI("[E] - " .. pickup.name, {
            icon = 'hand',
            style = {
                borderRadius = 25,
            }
        })
    end

    function respoint:onExit()
        lib.hideTextUI()
    end

    function respoint:nearby()
        if self.currentDistance < 3.0 and IsControlJustReleased(0, 38) then
            pickupFood(pickup)
            respoint:remove()
        end
    end
end

RegisterNetEvent("fs-fooddelivery:client:openDeliveryMenu")
AddEventHandler("fs-fooddelivery:client:openDeliveryMenu", function()
    if currentDelivery then
        exports.ox_lib:notify({title = 'FS-fooddelivery', type = "error", description = locale('already_started')})
        return
    end
    ESX.TriggerServerCallback('fs-fooddelivery:server:getPlayerLevelData', function(levelData) 
        lib.registerContext({
            id = "delivery_menu",
            title = locale('delivery_menu'),
            menu = 'deliverymenu_some',
            options = {
                {
                    title = locale('request_delivery'),
                    icon = "fas fa-utensils",
                    menu = 'deliverymenu_request',
                },
                {
                    title = locale('level') ..': ' ..levelData.level,
                    description = locale('reward_multiplier') ..': ' ..string.format("%.2f", levelData.rewardMultiplier),
                    icon = "fas fa-level-up-alt",
                    progress = levelData.levelPercentage,
                    metadata = {
                        {label = locale('current_level'), value = ': ' ..levelData.level},
                        {label = locale('xp_to_next_level'), value = ': ' ..levelData.xpToNextLevel ..'xp'},
                    }
                }
            }
        })
        
        local optionstable = {}
        for _,v in pairs(FS.deliveryVehicles) do
            table.insert(optionstable, {
                title = v.name,
                icon = "fas fa-car",
                description = locale('required_level') ..': '..v.level,
                disabled = levelData.level < v.level,
                event = "fs-fooddelivery:client:requestDelivery",
                args = {
                    vehicle = v.model,
                }
            })
        end
        lib.registerContext({
            id = "deliverymenu_request",
            title = locale('select_vehicle'),
            menu = 'deliverymenu_request',
            options = optionstable
        })
        lib.showContext("delivery_menu")
    end)
end)

RegisterNetEvent("fs-fooddelivery:client:requestDelivery")
AddEventHandler("fs-fooddelivery:client:requestDelivery", function(data)
    local vehicle = data.vehicle
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    chosenVehicle = vehicle

    if (FS.carDeposit.enabled) then
        exports.ox_inventory:RemoveItem(FS.moneyItem, FS.carDeposit.amount)
        exports.ox_lib:notify("success", locale('car_deposit', FS.carDeposit.amount))
    end

    lib.requestModel(vehicle)

    local veh = CreateVehicle(GetHashKey(vehicle), FS.vehicleLocation.x, FS.vehicleLocation.y, FS.vehicleLocation.z, FS.vehicleLocation.heading, true, false)
    SetVehicleOnGroundProperly(veh)
    TaskWarpPedIntoVehicle(playerPed, veh, -1)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleNumberPlateText(veh, "DELIVERY")
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleUndriveable(veh, false)

    startPickup()
end)