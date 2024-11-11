local Ox = require '@ox_core/lib/init'
local config = require 'config'

---@param spawnpoints vector4[]
---@return vector4 | nil
local function getFreeSpawnPoint(spawnpoints)
    for _, v in pairs(spawnpoints) do
        if not lib.getClosestVehicle(v.xyz, 2, false) then
            return v
        end
    end

    return nil
end

lib.callback.register("p-ox-vehicleshop:server:buyVehicle", function(src, model, paymentMethod, id)
    local spawnCoords = config.locations[id].spawnCoords

    local player = Ox.GetPlayer(src)
    local vehicleData = Ox.GetVehicleData(model)
    local freeSpawnPoint = getFreeSpawnPoint(spawnCoords)

    if not freeSpawnPoint then
        TriggerClientEvent("ox_lib:notify", src, {
            description = "Spawnipaikat o täynnä"
        })
        return false
    end

    if paymentMethod == "bank" then
        local account = player.getAccount()

        local data = account.removeBalance({
            amount = vehicleData.price,
            message = "Ajoneuvo osto"
        })

        if not data.success then
            TriggerClientEvent("ox_lib:notify", src, {
                description = "Sinulla ei ole tarpeeksi rahaa pankissa"
            })
            return false
        end
    else
        local success = exports.ox_inventory:RemoveItem(src, "cash", vehicleData.price)

        if not success then
            TriggerClientEvent("ox_lib:notify", src, {
                description = "Sinulla ei ole tarpeeksi käteistä"
            })
            return false
        end
    end

    TriggerClientEvent("ox_lib:notify", src, {
        description = ("Ostit ajoneuvon %s hintaan $%s"):format(vehicleData.name, vehicleData.price)
    })


    CreateThread(function()
        local vehicle = Ox.CreateVehicle({
            model = model,
            owner = player.charId,
        }, freeSpawnPoint.xyz, freeSpawnPoint.w)

        Wait(500)

        TaskWarpPedIntoVehicle(GetPlayerPed(src), vehicle.entity, -1)
    end)

    return true
end)
