local Rudinn, super = Class(Encounter)

function Rudinn:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Rudinn drew near!"

    -- Battle music ("battle" is rude buster)
    self.music = "battle"
    -- Enables the purple grid battle background
    self.background = true

    -- Add the enemy to the encounter
    self:addEnemy("rudinn")
end

-- TODO: Glowshard functions in enemies
function Rudinn:onGlowshardUse(item, user)
    local lines = ""
    for _, enemy in ipairs(Game.battle.enemies) do
        lines = lines .. "* " .. enemy.name .. " became enraptured!\n"
        enemy:addMercy(100)
    end
    Game.inventory:removeItem(item)
    return {
        "* "..user.chara.name.." used the GLOWSHARD!",
        lines,
        "* The GLOWSHARD disappeared!"
    }
end

-- TODO: Manual functions in enemies
function Rudinn:onManualUse(item, user)
    local lines = ""
    for _, enemy in ipairs(Game.battle.enemies) do
        if enemy.id == "rudinn" then
            lines = lines .. "* " .. enemy.name .. " was [color:blue]bored to tears[color:reset]!\n"
            enemy:setAnimation("tired")
            enemy:setTired(true)
            enemy.text_override = "Hey can\nyou read\nit more fast?"
        end
    end
    return {
        "* "..user.chara.name.." read the MANUAL!",
        lines
    }
end

return Rudinn