local wave, super = Class(Wave, "tasque/meowwow")

function wave:init()
    super.init(self)

    self.time = 140/30
end

function wave:onStart()
    local attackers = self:getAttackers()
    for _, attacker in ipairs(attackers) do
        attacker:toggleOverlay(true)
        attacker:getActiveSprite():setAnimation("meow_idle")
    end

    local ratio = self:getEnemyRatio()

    local attack_delay = 24/30 * ratio

    local start_delays = {}

    for i, attacker in ipairs(attackers) do
        if i == 1 then
            start_delays[attacker] = 0
        else
            start_delays[attacker] = attack_delay - (Utils.random(6/30, 18/30) * ratio)
        end
    end

    for attacker, start_delay in pairs(start_delays) do
        self.timer:after(start_delay, function()
            self.timer:everyInstant(attack_delay, function()
                Assets.playSound("electric_meow", 0.8, Utils.random(0.8, 1.2))

                attacker:getActiveSprite():setAnimation("meow")

                local attack_x, attack_y = attacker:getRelativePos(28/2, 34/2, Game.battle)
                local attack_dir = Utils.angle(attack_x, attack_y, Game.battle.soul.x, Game.battle.soul.y)

                self.timer:everyInstant(2/30, function()
                    self:spawnBullet("tasque/sound_wave", attack_x, attack_y, attack_dir)
                end, 8)

                self.timer:after(2/30 * 8, function()
                    attacker:getActiveSprite():setAnimation("meow_idle")
                end)
            end)
        end)
    end
end

function wave:onEnd(death)
    for _, attacker in ipairs(self:getAttackers()) do
        attacker:toggleOverlay(false)
    end
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

return wave