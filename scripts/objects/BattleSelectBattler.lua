---@class BattleSelectBattler : Object
---@overload fun(...) : BattleSelectBattler
local BattleSelectBattler, super = Class(Object)

function BattleSelectBattler:init(actor, chara, facing, x, y, height)
    super.init(self, x, y, 60, height or 120)

    self:setScale(4, 4)

    if type(actor) == "string" then
        actor = Registry.createActor(actor)
    end
    self.actor = actor
    self.chara = chara or actor.id

    self.actor_sprite = ActorSprite(actor)
    self.actor_sprite:setOrigin(0.5, 1)
    self.actor_sprite:setFacing(facing or "right")
    self:playAnimation()
    self:addChild(self.actor_sprite)

    self.facing = facing

    self.mask = self:addFX(MaskFX(self))

    self.slope = 0

    self.particles = {}
    self.particle_timer = 0

    self.particle_delay = 2/30
    self.particle_count = 4
    self.particle_targets = {}
    for i = 1, 120 do
        table.insert(self.particle_targets, i - 1)
    end
end

function BattleSelectBattler:setActor(actor)
    self.actor_sprite:remove()

    if type(actor) == "string" then
        actor = Registry.getActor(actor)
    end
    self.actor = actor

    self.actor_sprite = ActorSprite(actor)
    self.actor_sprite:setOrigin(0, 1)
    self.actor_sprite:setFacing(self.facing or "right")
    self:playAnimation()
    self:addChild(self.actor_sprite)
end

function BattleSelectBattler:playAnimation()
    if not self.actor_sprite:setAnimation("battle/intro") then
        self.actor_sprite:setAnimation("battle/idle")
    else
        self.actor_sprite.loop = false
        self.actor_sprite.anim_callback = function() self.actor_sprite:setAnimation("battle/idle") end
    end
end

function BattleSelectBattler:drawMask()
    local slope_half = (self.width / 2) * self.slope

    Draw.setColor(1, 1, 1)
    love.graphics.polygon("fill", 0, -slope_half, self.width, slope_half, self.width, 120, 0, 120)
end

function BattleSelectBattler:update()
    super.update(self)

    self.particle_timer = self.particle_timer + DT

    if self.particle_timer >= self.particle_delay then
        self.particle_timer = self.particle_timer - self.particle_delay

        local target = math.floor(Utils.random(0, #self.particle_targets)) + 1
        local y = self.particle_targets[target]
        table.remove(self.particle_targets, target)

        local particle_step = 120 / self.particle_count

        for i = 1, self.particle_count do
            table.insert(self.particles, {
                x = self.facing == "right" and self.width or -4,
                y = (y + (i * particle_step)) % 120
            })
        end

        if #self.particle_targets == 0 then
            for i = 1, 120 do
                table.insert(self.particle_targets, i - 1)
            end
        end
    end

    local to_remove = {}
    for _,particle in ipairs(self.particles) do
        if self.facing == "left" then
            particle.x = particle.x + DTMULT * 2

            if particle.x > self.width then
                table.insert(to_remove, particle)
            end
        else
            particle.x = particle.x - DTMULT * 2

            if particle.x < -4 then
                table.insert(to_remove, particle)
            end
        end
    end

    for _,particle in ipairs(to_remove) do
        Utils.removeFromTable(self.particles, particle)
    end
end

local function rgbToHsl(r, g, b, a)
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, l

    l = (max + min) / 2

    if max == min then
        h, s = 0, 0 -- achromatic
    else
        local d = max - min
        if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4
        end
        h = h / 6
    end

    return h, s, l, a or 1
end

local function hslToRgb(h, s, l, a)
    local r, g, b

    if s == 0 then
        r, g, b = l, l, l -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0   then t = t + 1 end
            if t > 1   then t = t - 1 end
            if t < 1/6 then return p + (q - p) * 6 * t end
            if t < 1/2 then return q end
            if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
            return p
        end

        local q
        if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
        local p = 2 * l - q

        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end

    return r, g, b, a
end

function BattleSelectBattler:draw()
    local center_y = self.height / 2
    local top_y = center_y - (120 / 2)

    local r,g,b = unpack(Mod.BATTLER_COLORS[self.chara] or Mod.BATTLER_COLORS["unknown"])

    Draw.setColor(r, g, b)
    love.graphics.rectangle("fill", 0, top_y, self.width, 120)

    local h,s,l = rgbToHsl(r, g, b)

    l = l + (1 - l) * 0.5

    Draw.setColor(hslToRgb(h, s, l))
    for _,particle in ipairs(self.particles) do
        love.graphics.rectangle("fill", math.floor(particle.x), math.floor(top_y + particle.y), 4, 1)
    end

    local actor_ox, actor_oy = unpack(Mod.BATTLER_OFFSETS[self.chara])

    self.actor_sprite.x = self.width / 2 + actor_ox
    self.actor_sprite.y = self.height / 2 + actor_oy

    super.draw(self)
end

return BattleSelectBattler