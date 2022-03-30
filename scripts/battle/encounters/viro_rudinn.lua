local ViroRudinn, super = Class(Encounter)

function ViroRudinn:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Virovirokun and Rudinn are\nfriends"

    -- Battle music ("battle" is rude buster)
    self.music = "battle"
    -- Enables the purple grid battle background
    self.background = true

    -- Add the enemy to the encounter
    self:addEnemy("virovirokun")
    self:addEnemy("rudinn")
end

-- TODO: Glowshard functions in enemies
function ViroRudinn:onGlowshardUse(user)
    local lines = ""
    for _, enemy in ipairs(Game.battle.enemies) do
        if enemy.id == "rudinn" then
            lines = lines .. "* " .. enemy.name .. " became enraptured!\n"
            enemy:addMercy(100)
        end
    end
    local inventory = Game.inventory:getStorage("item")
    for index,item in ipairs(inventory) do
        if item.id == "glowshard" then
            Game.inventory:removeItem("item", index)
            break
        end
    end
    return {
        "* "..user.chara.name.." used the GLOWSHARD!",
        lines,
        "* The GLOWSHARD disappeared!"
    }
end

return ViroRudinn