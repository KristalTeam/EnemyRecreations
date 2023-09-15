local bullet, super = Class(Bullet, "tasque/yarn_ball")

function bullet:init(x, y, dir, speed)
    -- Last argument = sprite path
    super:init(self, x, y, "bullets/tasque/yarn_spawn")

    self:setScale(0, 0)

    self.collidable = false

    self.spawning = true

    self.launch_direction = dir
    self.launch_speed = speed

    self.rotation = dir
    self.physics.match_rotation = true

    self.remove_offscreen = false

    self.tp = 2.8
end

function bullet:update()
    if self.spawning then
        self.rotation = self.launch_direction - math.sqrt(self.scale_x / 2) * math.rad(720)

        self.scale_x = Utils.approach(self.scale_x, 2, 0.2 * DTMULT)
        self.scale_y = Utils.approach(self.scale_y, 2, 0.2 * DTMULT)

        if self.scale_x == 2 then
            self.spawning = false

            self:setSprite("bullets/tasque/yarn", 0.1, true)
            self:setOriginExact(63/2, 18/2)
            self:setHitbox(55/2, 11/2, 19/2, 13/2)

            self.collidable = true

            self.rotation = self.launch_direction
            self.physics.gravity = 0.6
            self.physics.speed = self.launch_speed
        end
    end

    super.update(self)
end

return bullet