return {
    id = "rudinn",

    width = 35,
    height = 40,

    hitbox = {3, 24, 24, 16},

    flip = "right",

    path = "enemies/rudinn",
    default = "idle",

    animations = {
        ["idle"] = {"idle", 0.25, true},
        ["tired"] = {"tired", 0.25, true},
        ["spared"] = {"spared", 0.25, true},
        ["hurt"] = {"hurt", 0, false}
    },

    offsets = {
        ["idle"] = {6, -5},
        ["tired"] = {6, -5},
        ["spared"] = {4, -5},
        ["hurt"] = {1, 1},
    },
}