local config = require "config"
local function buildVehicleShopMenu(id, classes)
    local options = {}
    local vehicles = Ox.GetVehicleData()

    for class, _ in pairs(classes) do
        options[#options + 1] = {
            title = config.classLabels[class],
            onSelect = function()
                local options2 = {}
                local id = ('vehicleshop_category_%s'):format(class)

                for model, data in pairs(vehicles) do
                    options2[#options2 + 1] = {
                        title = data.name,
                        onSelect = function()
                            local input = lib.inputDialog('Valitse maksutapa', {
                                {
                                    type = 'select',
                                    label = 'Text input',
                                    options = {
                                        {
                                            value = "bank",
                                            label = "Pankki"
                                        },
                                        {
                                            value = "cash",
                                            label = "Käteinen"
                                        }

                                    },
                                    required = true
                                },
                            })

                            if not input or not input[1] then
                                lib.showContext(id)
                                return
                            end

                            --TODO: Pay & Give vehicle
                        end
                    }
                end

                lib.registerContext({
                    id = id,
                    title = config.classLabels[class],
                    menu = 'vehicleshop',
                    options = options2
                })

                lib.showContext(id)
            end
        }
    end

    lib.registerContext({
        id = ("vehicleshop_%s"):format(id),
        title = "Autokauppa",
        options = options
    })
end


CreateThread(function()
    for id, location in pairs(config.locations) do
        buildVehicleShopMenu(id, location.classes)

        --TODO: Spawn ped and register target
    end
end)
