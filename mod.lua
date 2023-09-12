Mod.PARTY_MEMBERS = {"kris", "susie", "ralsei", "noelle"}
Mod.ENEMIES = {"rudinn", "werewire", "virovirokun"}

Mod.BATTLER_COLORS = {
    ["kris"] = {0.12, 0.16, 0.8},
    ["susie"] = {0.87, 0, 0.43},
    ["ralsei"] = {0.11, 1, 0.3},
    ["noelle"] = {0.93, 1, 0},

    ["rudinn"] = {0.34, 1, 0.81},
    ["virovirokun"] = {0.22, 0, 0.5},
    ["werewire"] = {0.93, 1, 0},

    ["unknown"] = {0.1, 0.1, 0.1}
}

Mod.BATTLER_OFFSETS = {
    ["kris"] = {0, 26},
    ["susie"] = {0, 29},
    ["ralsei"] = {-3, 26},
    ["noelle"] = {0, 26},

    ["rudinn"] = {2, 21},
    ["virovirokun"] = {0, 31},
    ["werewire"] = {0, 46},

    ["unknown"] = {0, 20},
}

Mod.SPECIAL_ENCOUNTERS = {
    -- Accurate placements, fight tutorial
    ["werewire"] = {
        ["werewire"] = 2
    },
    -- Accurate placements
    ["virovirokun"] = {
        ["virovirokun"] = 2
    },
    --Glowshard / Manual support
    ["rudinn"] = {
        ["rudinn"] = 1
    },
    ["viro_rudinn"] = {
        ["virovirokun"] = 1,
        ["rudinn"] = 1
    }
}

Mod.greyscale_shader = love.graphics.newShader([[
    uniform float factor;
    uniform float brightness;

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
        vec4 sample = Texel(tex, texture_coords);
        float gray = 0.21 * sample.r + 0.71 * sample.g + 0.07 * sample.b;
        return vec4((sample.rgb * (1.0 - factor) + (gray * factor)) * brightness, sample.a);
    }
]])
Mod.greyscale_shader:send("factor", 1)
Mod.greyscale_shader:send("brightness", 1)

function Mod:init()
    self.battle_select = BattleSelectScreen()
end

function Mod:postInit()
    Game.state = "BATTLESELECT"

    Game.stage:addChild(self.battle_select)
end

function Mod:preUpdate()
    if Game.state == "BATTLESELECT" then
        self.battle_select.active = true
        self.battle_select.visible = true
    else
        self.battle_select.active = false
        self.battle_select.visible = false
    end
end