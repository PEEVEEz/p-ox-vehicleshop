return {
    classLabels = {
        [0] = "Compacts",
        [1] = "Sedans",
        [2] = "SUVs",
        [3] = "Coupes",
        [4] = "Muscle",
        [5] = "Sports Classics",
        [6] = "Sports",
        [7] = "Super",
        [8] = "Motorcycles",
        [9] = "Off-road",
        [10] = "Industrial",
        [11] = "Utility",
        [12] = "Vans",
        [13] = "Cycles",
        [14] = "Boats",
        [15] = "Helicopters",
        [16] = "Planes",
        [17] = "Service",
        [18] = "Emergency",
        [19] = "Military",
        [20] = "Commercial",
        [21] = "Trains",
        [22] = "Open Wheel"
    },
    locations = {
        {
            blip = {
                text = "Autokauppa",
                coords = vec3(-57.0106, -1098.8391, 0),
                sprite = 380
            },

            classes = {
                [7] = true
            },

            allowWeapons = false,

            ped = {
                model = `a_f_m_bevhills_01`,
                coords = vec4(-57.0106, -1098.8391, 26.4224, 28.0163)
            },

            interactionCoords = vec3(-57.7865, -1097.3596, 26.4224),

            camera = {
                coords = vec3(-46.9650, -1096.9, 28),
                rotation = vec3(-20, 0, -110)
            },

            showCoords = vec4(-41.4678, -1098.0692, 26.4223, 103.2050),

            spawnCoords = {
                vec4(-17.5473, -1079.8553, 26.6720, 154.7740),
                vec4(-14.5743, -1081.3319, 26.6721, 185.5948)
            }
        }
    }
}
