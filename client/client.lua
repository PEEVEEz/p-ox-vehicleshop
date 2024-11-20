local activeCamera = nil
local activeVehicle = nil
local menusRegistered = {}
local config <const> = require "config"
local Ox <const> = require '@ox_core/lib/init'

---@param coords vector3
---@param sprite number
---@param text string
local function createBlip(coords, sprite, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

---@param model string
---@param id number
local function vehicleSelected(model, id)
    if activeVehicle then
        DeleteEntity(activeVehicle)
        activeVehicle = nil
    end

    lib.requestModel(model, 50000)
    local coords <const> = config.locations[id].vehcileCoords
    local veh <const> = CreateVehicle(joaat(model), coords.x, coords.y, coords.z, coords.w or 0.0, false, true)
    activeVehicle = veh
end

---@param id number
local function createCamera(id)
    local cameraOptions <const> = config.locations[id].camera

    local cam <const> = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, cameraOptions.coords.x, cameraOptions.coords.y, cameraOptions.coords.z)
    SetCamRot(cam, cameraOptions.rotation.x, cameraOptions.rotation.y, cameraOptions.rotation.z, 2)
    RenderScriptCams(true, false, 0, true, true)

    activeCamera = cam
end

local function destroyCamera()
    RenderScriptCams(false, false, 0, true, true)
    if activeCamera then
        DestroyCam(activeCamera, true)
        activeCamera = nil
    end
end

local function closeVehicleShop()
    if activeVehicle then
        DeleteEntity(activeVehicle)
        activeVehicle = nil
    end

    SetEntityInvincible(cache.ped, false)
    FreezeEntityPosition(cache.ped, false)
    SetEntityCollision(cache.ped, true, true)
    destroyCamera()
end

---@param id number
---@param classes any
---@return string
local function buildVehicleShopMenu(id, classes)
    local options = {}
    local vehicles <const> = Ox.GetVehicleData()

    for class, _ in pairs(classes) do
        options[#options + 1] = {
            title = locale(("class_%s"):format(class)),
            onSelect = function()
                local options2 = {}
                local categoryMenuId <const> = ('vehicleshop_category_%s'):format(class)

                for model, data in pairs(vehicles) do
                    if data.class == class and not data.weapons or (data.weapons and config.locations[id].weaponVehicles) then
                        options2[#options2 + 1] = {
                            title = data.name,
                            onSelect = function()
                                local vehicleMenuId <const> = ("vehicle_%s"):format(data.name)
                                vehicleSelected(model, id)

                                local function buy(account)
                                    local success = lib.callback.await("p-ox-vehicleshop:server:buyVehicle",
                                        false,
                                        model, account,
                                        id)

                                    if success then
                                        closeVehicleShop()
                                    else
                                        lib.showContext(vehicleMenuId)
                                    end
                                end

                                lib.registerContext({
                                    id = vehicleMenuId,
                                    title = locale("select_payment_method", data.name),
                                    menu = categoryMenuId,
                                    onExit = function()
                                        closeVehicleShop()
                                    end,
                                    options = {
                                        {
                                            title = locale("bank"),
                                            onSelect = buy
                                        },
                                        {
                                            title = locale("cash"),
                                            onSelect = buy
                                        }
                                    }
                                })

                                lib.showContext(vehicleMenuId)
                            end
                        }
                    end
                end

                lib.registerContext({
                    id = categoryMenuId,
                    onExit = function()
                        closeVehicleShop()
                    end,
                    title = locale(("class_%s"):format(class)),
                    menu = ("vehicleshop_%s"):format(id),
                    options = options2
                })

                lib.showContext(categoryMenuId)
            end
        }
    end


    lib.registerContext({
        id = ("vehicleshop_%s"):format(id),
        title = config.locations[id].name,
        onExit = function()
            closeVehicleShop()
        end,
        options = options
    })

    return ("vehicleshop_%s"):format(id)
end

---@param id number
---@param classes any
local function openVehicleShop(id, classes)
    if not menusRegistered[id] then
        menusRegistered[id] = buildVehicleShopMenu(id, classes)
    end

    createCamera(id)
    lib.showContext(menusRegistered[id])

    SetEntityInvincible(cache.ped, true)
    FreezeEntityPosition(cache.ped, true)
    SetEntityCollision(cache.ped, false, false)
end

CreateThread(function()
    for id, location in pairs(config.locations) do
        createBlip(location.blip.coords.xyz, location.blip.sprite, location.name)

        if location.ped then
            lib.requestModel(location.ped.model, 50000)
            local ped = CreatePed(26, location.ped.model,
                location.ped.coords.x, location.ped.coords.y, location.ped.coords.z, 0.0, false, false)
            SetEntityHeading(ped, location.ped.coords.w)
            SetBlockingOfNonTemporaryEvents(ped, true)
            FreezeEntityPosition(ped, true)

            if config.useTarget then
                exports.ox_target:addLocalEntity(ped, {
                    {
                        label = locale("open_vehicleshop_target"),
                        icon = "fas fa-car",
                        onSelect = function()
                            openVehicleShop(id, location.classes)
                        end
                    }
                })
            end
        end

        if not config.useTarget then
            local markerPoint <const> = lib.points.new({
                coords = location.interactionCoords,
                distance = 5,
            })

            local marker = lib.marker.new(lib.table.merge(location.marker, { coords = location.interactionCoords }))
            function markerPoint:nearby()
                marker:draw()
            end

            local interactionPoint <const> = lib.points.new({
                coords = location.interactionCoords,
                distance = 2,
            })

            function interactionPoint:onEnter()
                lib.showTextUI(locale("open_vehicleshop"))
            end

            function interactionPoint:onExit()
                lib.hideTextUI()
            end

            function interactionPoint:nearby()
                if IsControlJustReleased(0, 38) then
                    openVehicleShop(id, location.classes)
                end
            end
        end
    end
end)
