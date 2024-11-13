local config = require "config"
local Ox = require '@ox_core/lib/init'

local activeCamera = nil
local activeVehicle = nil

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

local function vehicleSelected(model, id)
    if activeVehicle then
        DeleteEntity(activeVehicle)
        activeVehicle = nil
    end

    lib.requestModel(model, 50000)
    local coords = config.locations[id].showCoords
    local veh = CreateVehicle(joaat(model), coords.x, coords.y, coords.z, coords.w or 0.0, false, true)
    activeVehicle = veh
end

local function createCamera(id)
    local cameraOptions = config.locations[id].camera

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

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

    destroyCamera()
end

local function buildVehicleShopMenu(id, classes)
    local options = {}
    local vehicles = Ox.GetVehicleData()

    for class, _ in pairs(classes) do
        options[#options + 1] = {
            title = config.classLabels[class],
            onSelect = function()
                local options2 = {}
                local menuId = ('vehicleshop_category_%s'):format(class)

                for model, data in pairs(vehicles) do
                    if data.class == class and not data.weapons or (data.weapons and config.locations[id].allowWeapons) then
                        options2[#options2 + 1] = {
                            title = data.name,
                            onSelect = function()
                                vehicleSelected(model, id)

                                lib.registerContext({
                                    id = ("vehicle_%s"):format(data.name),
                                    title = ("Valitse maksutapa (%s)"):format(data.name),
                                    menu = menuId,
                                    onExit = function()
                                        closeVehicleShop()
                                    end,
                                    options = {
                                        {
                                            title = "Kortti",
                                            onSelect = function()
                                                local success = lib.callback.await("p-ox-vehicleshop:server:buyVehicle",
                                                    false,
                                                    model, "bank",
                                                    id)

                                                if success then
                                                    closeVehicleShop()
                                                else
                                                    lib.showContext(("vehicle_%s"):format(data.name))
                                                end
                                            end
                                        },
                                        {
                                            title = "Käteinen",
                                            onSelect = function()
                                                local success = lib.callback.await("p-ox-vehicleshop:server:buyVehicle",
                                                    false,
                                                    model, "cash",
                                                    id)

                                                if success then
                                                    closeVehicleShop()
                                                else
                                                    lib.showContext(("vehicle_%s"):format(data.name))
                                                end
                                            end
                                        }
                                    }
                                })

                                lib.showContext(("vehicle_%s"):format(data.name))
                            end
                        }
                    end
                end

                lib.registerContext({
                    id = menuId,
                    onExit = function()
                        closeVehicleShop()
                    end,
                    title = config.classLabels[class],
                    menu = ("vehicleshop_%s"):format(id),
                    options = options2
                })

                lib.showContext(menuId)
            end
        }
    end


    lib.registerContext({
        id = ("vehicleshop_%s"):format(id),
        title = "Autokauppa",
        onExit = function()
            closeVehicleShop()
        end,
        options = options
    })

    return ("vehicleshop_%s"):format(id)
end

CreateThread(function()
    for id, location in pairs(config.locations) do
        createBlip(location.blip.coords.xyz, location.blip.sprite, location.blip.text)

        local menuId = buildVehicleShopMenu(id, location.classes)

        lib.requestModel(location.ped.model, 50000)
        local ped = CreatePed(26, location.ped.model,
            location.ped.coords.x, location.ped.coords.y, location.ped.coords.z, 0.0, false, false)
        SetEntityHeading(ped, location.ped.coords.w)
        FreezeEntityPosition(ped, true)

        local point = lib.points.new({
            coords = location.interactionCoords,
            distance = 5,
        })

        function point:nearby()
            DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 200,
                20, 20, 50, false, true, 2, false, nil, nil, false)
        end

        local point2 = lib.points.new({
            coords = location.interactionCoords,
            distance = 2,
        })

        function point2:onEnter()
            lib.showTextUI('[E] - Autokauppa')
        end

        function point2:onExit()
            lib.hideTextUI()
        end

        function point2:nearby()
            if IsControlJustReleased(0, 38) then
                createCamera(id)
                lib.showContext(menuId)
            end
        end
    end
end)
