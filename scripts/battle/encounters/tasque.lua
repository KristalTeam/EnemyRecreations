local encounter, super = Class("custom_encounter")

function encounter:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Tasques crossed your path!"

    -- Battle music ("battle" is rude buster)
    self.music = "battle"
    -- Enables the purple grid battle background
    self.background = true

    -- Add the tasques to the encounter
    self:addEnemy("tasque", 488, 130)
    self:addEnemy("tasque", 528, 240)
end

return encounter