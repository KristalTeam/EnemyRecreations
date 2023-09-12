---@class BattleSelectScreen : Object
---@overload fun(...) : BattleSelectScreen
local BattleSelectScreen, super = Class(Object)

function BattleSelectScreen:init()
    super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    self.layer = 1000

    self.state = nil
    self.state_manager = StateManager("NONE", self, true)
    self.state_manager:addState("SHOWCASE", {update = self.showcaseUpdate})
    self.state_manager:addState("INTRO", {enter = self.introEnter})
    self.state_manager:addState("SELECT", {update = self.selectUpdate})
    self.state_manager:addState("FIGHT", {enter = self.fightEnter})

    self.music = Music()

    self.timer = Timer()
    self:addChild(self.timer)

    self.flash_amount = 0

    self.title_y = 85
    self.title_slope = -(60 / SCREEN_WIDTH)

    self.party = {}
    self.enemies = {}

    self.party_option_scroll = self:addChild(Object(248, math.floor(self.title_y + (SCREEN_HEIGHT - self.title_y)/2) - 32))
    self.enemy_option_scroll = self:addChild(Object(328, math.floor(self.title_y + (SCREEN_HEIGHT - self.title_y)/2) - 32))

    self.party_options = {}
    self.enemy_options = {}

    for i,party_member in ipairs(Mod.PARTY_MEMBERS) do
        local option = BattleSelectButton(party_member, "party", 0, (i - 1) * (64 + 4))
        self.party_option_scroll:addChild(option)
        table.insert(self.party_options, option)
    end

    for i,enemy in ipairs(Mod.ENEMIES) do
        local option = BattleSelectButton(enemy, "enemies", 0, (i - 1) * (64 + 4))
        self.enemy_option_scroll:addChild(option)
        table.insert(self.enemy_options, option)
    end

    self.last_party_option = math.floor((#self.party_options - 1) / 2) + 1
    self.last_enemy_option = math.floor((#self.enemy_options - 1) / 2) + 1

    self.selected_option = self.last_party_option
    self.selected_column = 1

    self.party_option_scroll.y = self.party_option_scroll.y - (self.last_party_option - 1) * (64 + 4)
    self.enemy_option_scroll.y = self.enemy_option_scroll.y - (self.last_enemy_option - 1) * (64 + 4)

    self.transition_out = 0
end

function BattleSelectScreen:setState(state)
    self.state_manager:setState(state)
end

function BattleSelectScreen:onAddToStage(stage)
    super.onAddToStage(self, stage)

    for _,chara in ipairs(Game.party) do
        local battler = BattleSelectBattler(chara:getActor(false), chara.id, "right", 0)
        self:addChild(battler)
        table.insert(self.party, battler)
    end

    self:resizeBattlers()

    self:setState("INTRO")
end

function BattleSelectScreen:introEnter()
    self.transition_out = 0

    Assets.playSound("weaponpull")
    Assets.playSound("shineselect", 1, 0.7)

    for _,party in ipairs(self.party) do
        party:playAnimation()
    end
    for _,enemy in ipairs(self.enemies) do
        enemy:playAnimation()
    end

    if not Kristal.Config["simplifyVFX"] then
        self.flash_amount = 1
        self.timer:tween(0.5, self, {flash_amount = 0})
    end

    self.timer:after(0.5, function()
        if not self.music:isPlaying() then
            self.music:play("boxing_boss", 0.7)
        end

        self:setState("SELECT")
    end)
end

function BattleSelectScreen:getSpecialEncounter()
    local enemies_count = {}
    for _,enemy in ipairs(self.enemies) do
        enemies_count[enemy.chara] = (enemies_count[enemy.chara] or 0) + 1
    end

    for encounter,list in pairs(Mod.SPECIAL_ENCOUNTERS) do
        local all_equal = true

        for enemy,count in pairs(enemies_count) do
            if list[enemy] ~= count then
                all_equal = false
                break
            end
        end

        for enemy,count in pairs(list) do
            if enemies_count[enemy] ~= count then
                all_equal = false
                break
            end
        end

        if all_equal then
            return encounter
        end
    end
end

function BattleSelectScreen:fightEnter()
    Assets.playSound("cardrive")

    self.timer:tween(0.5, self, {transition_out = 1}, "in-cubic")

    self.music:fade(0, 1, function() self.music:stop() end)

    self.timer:after(1.5, function()
        Game:setPartyMembers()
        for _,party in ipairs(self.party) do
            Game:addPartyMember(party.chara)
        end

        local encounter = self:getSpecialEncounter()

        if not encounter then
            encounter = Registry.createEncounter("custom_encounter")

            for _,enemy in ipairs(self.enemies) do
                encounter:addEnemy(enemy.chara)
            end
        end

        Game:encounter(encounter, false)
    end)
end

function BattleSelectScreen:resizeBattlers()
    local party_count = #self.party
    local enemy_count = #self.enemies

    local party_y = math.floor(self.title_y - 80 * self.title_slope)
    local enemy_y = math.floor(self.title_y + 320 * self.title_slope)

    local party_height = SCREEN_HEIGHT - party_y
    local enemy_height = SCREEN_HEIGHT - enemy_y

    local party_step = party_height / party_count
    local enemy_step = enemy_height / enemy_count

    local has_party = {}
    local has_enemy = {}

    for i, battler in ipairs(self.party) do
        has_party[battler.chara] = true

        battler.y = party_y + party_step * (i - 1)
        battler.height = party_step / 4

        if i == 1 then
            battler.slope = 0
        else
            battler.slope = -self.title_slope * math.pow(-1, i)
        end

        battler:setLayer(i)
    end

    for i, battler in ipairs(self.enemies) do
        has_enemy[battler.chara] = true

        battler.y = enemy_y + enemy_step * (i - 1)
        battler.height = enemy_step / 4

        if i == 1 then
            battler.slope = 0
        else
            battler.slope = self.title_slope * math.pow(-1, i)
        end
    end

    for _, option in ipairs(self.party_options) do
        option.selected = has_party[option.chara]
    end

    for _, option in ipairs(self.enemy_options) do
        option.selected = has_enemy[option.chara]
    end
end

function BattleSelectScreen:selectUpdate()
    local options

    if self.selected_column == 1 then
        options = self.party_options
        self.last_party_option = self.selected_option
    else
        options = self.enemy_options
        self.last_enemy_option = self.selected_option
    end

    if self.selected_column == 1 and Input.pressed("right") then
        Assets.stopAndPlaySound("ui_move")
        self.selected_column = 2
        self.selected_option = self.last_enemy_option
        options = self.enemy_options
    end
    if self.selected_column == 2 and Input.pressed("left") then
        Assets.stopAndPlaySound("ui_move")
        self.selected_column = 1
        self.selected_option = self.last_party_option
        options = self.party_options
    end

    if Input.pressed("down") then
        Assets.stopAndPlaySound("ui_move")
        self.selected_option = (self.selected_option) % #options + 1
    end
    if Input.pressed("up") then
        Assets.stopAndPlaySound("ui_move")
        self.selected_option = (self.selected_option - 2) % #options + 1
    end

    if self.selected_column == 1 then
        self.party_option_scroll.y = self.party_option_scroll.init_y - (self.selected_option - 1) * (64 + 4)
    else
        self.enemy_option_scroll.y = self.enemy_option_scroll.init_y - (self.selected_option - 1) * (64 + 4)
    end

    local option = options[self.selected_option]

    local battlers = self.selected_column == 1 and self.party or self.enemies
    local battlers_changed = false

    local already_selected = nil
    for i,battler in ipairs(battlers) do
        if battler.chara == option.chara then
            already_selected = i
        end
    end

    if Input.pressed("confirm") then
        if self.selected_column == 1 and (#self.party == 3 or already_selected) then
            Assets.stopAndPlaySound("ui_cant_select")

        elseif self.selected_column == 1 then
            battlers_changed = true

            Assets.stopAndPlaySound("ui_select")
            Assets.stopAndPlaySound("weaponpull_fast", 0.8)

            local chara = Game:getPartyMember(option.chara)
            local new_battler = BattleSelectBattler(chara:getActor(false), chara.id, "right", 0)
            self:addChild(new_battler)
            table.insert(self.party, new_battler)

            option.selected = true

        elseif self.selected_column == 2 then
            battlers_changed = true

            Assets.stopAndPlaySound("ui_select")
            Assets.playSound("tensionhorn", 1)

            local enemy = Registry.createEnemy(option.chara)
            local new_battler = BattleSelectBattler(enemy.actor, enemy.id, "left", 400)
            self:addChild(new_battler)
            table.insert(self.enemies, new_battler)

            option.selected = true
        end
    end

    if Input.pressed("cancel") then
        if not already_selected then
            Assets.stopAndPlaySound("ui_cant_select")

        else
            battlers_changed = true

            Assets.stopAndPlaySound("ui_cancel")

            battlers[already_selected]:remove()
            table.remove(battlers, already_selected)
        end
    end

    if battlers_changed then
        self:resizeBattlers()
    end

    if Input.pressed("menu") then
        if #self.party == 0 or #self.enemies == 0 then
            Assets.stopAndPlaySound("ui_cant_select")
        else
            self:setState("FIGHT")
        end
    end
end

function BattleSelectScreen:update()
    super.update(self)

    self.state_manager:update()
end

function BattleSelectScreen:showcaseUpdate()
    self.transition_out = 1

    if Input.pressed("confirm") then
        self.timer:after(0, function()
            self:setState("INTRO")
        end)
    end
end

function BattleSelectScreen:draw()
    Draw.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    Draw.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 240, 0, 160, SCREEN_HEIGHT)

    Draw.setColor(0.05, 0.05, 0.05)
    love.graphics.rectangle("fill", 248, 0, 64, SCREEN_HEIGHT)
    love.graphics.rectangle("fill", 328, 0, 64, SCREEN_HEIGHT)

    super.draw(self)

    if self.state == "SELECT" then
        Draw.setColor(1, 1, 1)
        if self.selected_column == 1 then
            Draw.draw(Assets.getTexture("battleselect/selection"), self.party_option_scroll.init_x - 2, self.party_option_scroll.init_y - 2, 0, 2, 2)
        else
            Draw.draw(Assets.getTexture("battleselect/selection"), self.enemy_option_scroll.init_x - 2, self.enemy_option_scroll.init_y - 2, 0, 2, 2)
        end
    end

    Draw.setColor(1, 1, 1)
    love.graphics.setLineWidth(8)
    love.graphics.setLineStyle("rough")
    for i, battler in ipairs(self.party) do
        if i > 1 then
            local slope_off = battler.slope * (240 / 2)
            love.graphics.line(battler.x, battler.y - slope_off, battler.x + 240, battler.y + slope_off)
        end
    end
    for i, battler in ipairs(self.enemies) do
        if i > 1 then
            local slope_off = battler.slope * (240 / 2)
            love.graphics.line(battler.x, battler.y - slope_off, battler.x + 240, battler.y + slope_off)
        end
    end
    love.graphics.setLineWidth(1)

    Draw.setColor(0, 0, 0)
    love.graphics.polygon("fill", 0, 0, 0, self.title_y - self.title_slope * (SCREEN_WIDTH / 2), SCREEN_WIDTH, self.title_y + self.title_slope * (SCREEN_WIDTH / 2), SCREEN_WIDTH, 0)

    Draw.setColor(1, 1, 1)

    love.graphics.push()
    love.graphics.translate(8, 38)
    love.graphics.shear(0, self.title_slope)
    love.graphics.translate(8, 0)
    love.graphics.scale(2, 2)

    love.graphics.setFont(Assets.getFont("main"))
    love.graphics.print("Select Your Fight!")

    love.graphics.pop()

    love.graphics.setBlendMode("add")
    Draw.setColor(self.flash_amount, self.flash_amount, self.flash_amount)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    love.graphics.setBlendMode("alpha")

    if self.transition_out > 0 then
        Draw.setColor(0, 0, 0)
        local left = -120 + (SCREEN_WIDTH + 120) * self.transition_out
        love.graphics.polygon("fill", math.min(left, 0), 0, left + 120, 0, left, SCREEN_HEIGHT, math.min(left, 0), SCREEN_HEIGHT)
    end
end

return BattleSelectScreen