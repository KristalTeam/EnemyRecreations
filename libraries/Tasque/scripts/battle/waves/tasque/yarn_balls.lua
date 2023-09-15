local wave, super = Class(Wave, "tasque/yarn_balls")

function wave:init()
    super.init(self)

    self.time = 140/30
end

function wave:onStart()
    local ratio = self:getEnemyRatio()

    local count = 0

    self.timer:every((10/30) * ratio, function()
        for _, attacker in ipairs(self:getAttackers()) do
            local x, y = attacker:getRelativePos(0, 0)

            local speed = self:remapValue(40, 200, y, 8, 16)
            local target_x = (count % 3 == 2) and Game.battle.soul.x or (Game.battle.arena.right - Utils.random(250))

            local direction = self:getLaunchDirection(speed, target_x - x, 0.5) or math.rad(-135)

            self:spawnBullet("tasque/yarn_ball", x, y, direction, speed)
        end

        count = count + 1
    end)
end

function wave:getEnemyRatio()
    local enemies = #Game.battle:getActiveEnemies()
    if enemies <= 1 then
        return 1
    elseif enemies == 2 then
        return 1.6
    elseif enemies >= 3 then
        return 2.3
    end
end

function wave:getLaunchDirection(speed, dx, gravity)
    if (speed ^ 2) / gravity <= math.abs(dx) then
        return nil
    end
    local angle = math.asin((dx * gravity) / (speed ^ 2)) / 2
    return -math.rad(90) + angle
end

function wave:remapValue(old_min, old_max, val, new_min, new_max)
    if old_min == old_max then
        return new_min
    end
    local t = (val - old_min) / (old_max - old_min)
    return Utils.lerp(new_min, new_max, t, true)
end

return wave