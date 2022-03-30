local TestMap, super = Class(Map)

TestMap.ENCOUNTERS = {
    "virovirokun",
    "rudinn",
    "viro_rudinn"
}

function TestMap:load()
    super:load(self)

    self:spawnEnemy()
end

function TestMap:spawnEnemy()
    if self.enemy then
        self.enemy:remove()
        self.enemy = nil
    end

    local encounter_id = self:getFlag("encounter", 1)
    local encounter

    if encounter_id == 0 then
        local enemies = self:getFlag("enemies", {})

        if #enemies > 0 then
            encounter = Registry.createEncounter("test", enemies)
        end
    else
        encounter = Registry.createEncounter(self.ENCOUNTERS[encounter_id])
    end

    if encounter then
        local chosen_enemy = Utils.pick(encounter.queued_enemy_spawns)
        local ex, ey = self:getMarker("enemy_start")

        self.enemy = ChaserEnemy(chosen_enemy.actor.id, ex, ey, {encounter = encounter, facing = "left"})
        self.world:spawnObject(self.enemy)
    end
end

function TestMap:respawn()
    self:spawnEnemy()

    for _,chara in ipairs(Game.party) do
        Game.world:getPartyCharacter(chara):remove()
    end
    Game.world:spawnParty()
end

function TestMap:update(dt)
    local encounter = self:getFlag("encounter", 1)

    local custom_enemies = self:getFlag("enemies", {})
    if not Game.battle and (not self.enemy or not self.enemy.parent) and (encounter ~= 0 or #custom_enemies > 0) then
        self:respawn()
    end

    if Input.keyPressed("[") then
        if encounter <= 1 then
            self:setFlag("encounter", #self.ENCOUNTERS)
        else
            self:setFlag("encounter", encounter - 1)
        end
        self:spawnEnemy()
    elseif Input.keyPressed("]") then
        if encounter >= #self.ENCOUNTERS then
            self:setFlag("encounter", 1)
        else
            self:setFlag("encounter", encounter + 1)
        end
        self:spawnEnemy()
    end

    super:update(dt)
end

function TestMap:draw()
    super:draw(self)

    if self.world.state ~= "GAMEPLAY" then return end

    local font = Assets.getFont("main")
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)

    local encounter_id = self:getFlag("encounter", 1)
    local progress_text = "["..tostring(encounter_id).."/"..tostring(#self.ENCOUNTERS).."]"
    if encounter_id == 0 then
        love.graphics.print("Encounter: Custom "..progress_text, 0, 0)
    else
        love.graphics.print("Encounter: "..(self.ENCOUNTERS[encounter_id]).." "..progress_text, 0, 0)
    end

    if not self.enemy then return end

    local height = font:getHeight()
    for i,enemy in ipairs(self.enemy.encounter.queued_enemy_spawns) do
        love.graphics.print("- "..enemy.name, 5, i * height)
    end
end

return TestMap