local actor, super = Class(Actor, "tasque")

function actor:init()
    -- Display name (optional)
    self.name = "Tasque"

    -- Width and height for this actor, used to determine its center
    self.width = 48
    self.height = 40

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = {0, 16, 48, 24}

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = {1, 0, 0}

    -- Whether this actor flips horizontally (optional, values are "right" or "left", indicating the flip direction)
    self.flip = "right"

    -- Path to this actor's sprites (defaults to "")
    self.path = "enemies/tasque"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "idle"

    -- Sound to play when this actor speaks (optional)
    self.voice = nil
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = nil
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = nil

    -- Whether this actor as a follower will blush when close to the player
    self.can_blush = false

    -- Table of talk sprites and their talk speeds (default 0.25)
    self.talk_sprites = {}

    -- Table of sprite animations
    self.animations = {
        ["idle"] = {"idle", 6/30, true},
        ["spared"] = {"spared", 0, false},
        ["hurt"] = {"hurt", 0, false},

        ["meow_idle"] = {"meow_1", 0, false},
        ["meow"] = {"meow", 2/30, true}
    }

    -- Table of sprite offsets (indexed by sprite name)
    self.offsets = {}
end

return actor