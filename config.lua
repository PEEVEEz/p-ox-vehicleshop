return {
    useTarget = false, -- requires ped in vehicleshop

    locations = {
        {
            blip = {
                coords = vec3(-57.0106, -1098.8391, 0),
                text = "Vehicleshop",
                sprite = 380,
            },

            weaponVehicles = false,

            classes = {
                [0] = true,
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
                [6] = true,
                [7] = true,
                [8] = true,
                [9] = true,
                [12] = true,
                [13] = true,
            },

            ped = {
                model = `a_f_m_bevhills_01`,
                coords = vec4(-57.0106, -1098.8391, 26.4224, 28.0163)
            },

            interactionCoords = vec3(-57.7865, -1097.3596, 26.4224),

            camera = {
                coords = vec3(-46.9650, -1096.9, 28),
                rotation = vec3(-20, 0, -110)
            },

            vehcileCoords = vec4(-41.4678, -1098.0692, 26.4223, 103.2050),

            spawnCoords = {
                vec4(-17.5473, -1079.8553, 26.6720, 154.7740),
                vec4(-14.5743, -1081.3319, 26.6721, 185.5948)
            }
        }
    }
}
