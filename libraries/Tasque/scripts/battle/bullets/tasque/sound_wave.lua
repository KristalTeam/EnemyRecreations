local bullet, super = Class(Bullet, "tasque/sound_wave")

function bullet:init(x, y, dir)
    -- Last argument = sprite path
    super:init(self, x, y, "bullets/tasque/meow")

    self:setHitbox(2, 3, 2, 4)

    self.rotation = dir

    self.physics.speed = 7
    self.physics.match_rotation = true

    self.tp = 0.56
end

function bullet:update()
    self.scale_x = self.scale_x + (0.025 * (self.physics.speed / 7)) * 2 * DTMULT
    self.scale_y = self.scale_y + (0.025 * (self.physics.speed / 7)) * 2 * DTMULT

    super:update(self)
end

return bullet