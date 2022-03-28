local EncounterTest, super = Class(Encounter)

function EncounterTest:init(enemies)
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Test"

    -- Battle music ("battle" is rude buster)
    self.music = "battle"
    -- Enables the purple grid battle background
    self.background = true

    for _,enemy in ipairs(enemies) do
        self:addEnemy(enemy)
    end
end

return EncounterTest