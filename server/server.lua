local config <const> = require 'config'
local Ox <const> = require '@ox_core/lib/init'

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

---@param source number
---@param model string | number
---@param paymentMethod "cash" | "bank"
---@param id number
---@return boolean
lib.callback.register("p-ox-vehicleshop:server:buyVehicle", function(source, model, paymentMethod, id)
    local player <const> = Ox.GetPlayer(source)
    local location <const> = config.locations[id]
    local vehicleData <const> = Ox.GetVehicleData(model)
    local freeSpawnPoint <const> = getFreeSpawnPoint(location.spawnCoords)

    if not freeSpawnPoint then
        TriggerClientEvent("ox_lib:notify", source, {
            description = locale("no_free_spawnpositions")
        })
        return false
    end

    if paymentMethod == "bank" then
        local account <const> = player.getAccount()

        local data <const> = account.removeBalance({
            amount = vehicleData.price,
            message = "Vehicleshop"
        })

        if not data.success then
            TriggerClientEvent("ox_lib:notify", source, {
                description = locale("not_enough_money_bank"),
                type = "error"
            })
            return false
        end
    else
        local success <const> = exports.ox_inventory:RemoveItem(source, "cash", vehicleData.price)

        if not success then
            TriggerClientEvent("ox_lib:notify", source, {
                description = locale("not_enough_money_cash"),
                type = "error"
            })
            return false
        end
    end

    TriggerClientEvent("ox_lib:notify", source, {
        description = locale("you_bought_vehicle", vehicleData.name, vehicleData.price)
    })

    CreateThread(function()
        local vehicle <const> = Ox.CreateVehicle({
            model = model,
            owner = player.charId,
        }, freeSpawnPoint.xyz, freeSpawnPoint.w)

        Wait(500)
        TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle.entity, -1)
    end)

    return true
end)
