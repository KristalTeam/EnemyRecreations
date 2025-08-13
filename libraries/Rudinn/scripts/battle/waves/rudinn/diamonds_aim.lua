local DiamondsAim, super = Class(Wave)

function DiamondsAim:init()
	super.init(self)

    self.time = 140/30
end

function DiamondsAim:onStart()
    local ratio = self:getEnemyRatio()

    self.timer:every(12/30*ratio, function()
        for _, attacker in ipairs(self:getAttackers()) do
            local soul = Game.battle.soul

            local dir = 30 + love.math.random(120)
            local radius = 140 + love.math.random(80)

            -- NOTE: GML angles have 90 as NORTH, so we need to invert our angle to achieve the same
            local x = math.cos(math.rad(-dir)) * radius
            local y = math.sin(math.rad(-dir)) * radius
		
            local diamond = self:spawnBullet("rudinn/diamond_black", soul.x + x, soul.y + y)
        end
    end)
end

function DiamondsAim:getEnemyRatio()
    local enemies = #Game.battle:getActiveEnemies()
    if enemies <= 1 then
        return 1
    elseif enemies == 2 then
        return 1.6
    elseif enemies >= 3 then
        return 2.3
    end
end

return DiamondsAim