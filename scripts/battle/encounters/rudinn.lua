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
function Rudinn:onGlowshardUse(user)
    local lines = ""
    for _, enemy in ipairs(Game.battle.enemies) do
        lines = lines .. "* " .. enemy.name .. " became enraptured!\n"
        enemy:addMercy(100)
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

return Rudinn