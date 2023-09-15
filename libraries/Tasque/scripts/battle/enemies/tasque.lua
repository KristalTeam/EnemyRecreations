local enemy, super = Class(EnemyBattler, "tasque")

function enemy:init()
    super:init(self)

    -- Enemy name
    self.name = "Tasque"
    -- Sets the actor, which handles the enemy's sprites
    self:setActor("tasque")

    -- Enemy health
    self.max_health = 240
    self.health = 240
    -- Enemy attack (determines bullet damage)
    self.attack = 8
    -- Enemy defense (usually 0)
    self.defense = 0
    -- Enemy reward
    self.money = 75

    -- Mercy given when sparing this enemy before its spareable (20% for basic enemies)
    self.spare_points = 20

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
        "tasque/meowwow",
        "tasque/yarn_balls",
    }

    -- Dialogue randomly displayed in the enemy's speech bubble
    self.dialogue = {
        "meowowme\nowowmeow",
        "meowowme\nmeowmeow",
        "meowowme\nowowowow",
        "meowowow\nmeowowow",
    }
    -- Dialogue used after the Petting act
    self.pet_dialogue = "owowowmememeowme\nowmemeowowmemeow\nowmeowmemeowmeow"

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "This stray cat is in\nneed of some management."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* Tasque is batting a ball of\nlow-poly yarn.",
        "* Tasque is meowing to be\n%s.",
        "* Tasque cleans with a sawtooth\ntongue.",
        "* Tasque wags its tail in a sine\nwave.",
        "* Smells like plastic cartridge."
    }
    -- Text displayed at the bottom of the screen when the enemy is tired
    if Kristal.Version < SemVer('0.9.0-dev') then
        self.low_health_text = "* Tasque is beeping dangerously."
    else
        self.tired_text = "* Tasque is beeping dangerously."
    end
    -- Text displayed at the bottom of the screen when the enemy is spareable
    self.spareable_text = "* Tasque is emitting an 8-bit purr."

    -- Remember acts to only do dialogue once
    self.acted_susie = false
    self.acted_ralsei = false
    self.acted_noelle = false

    -- Basic petting act
    self:registerShortAct("Petting")

    -- Party acts
    self:registerAct("Roar", "", {"susie"})
    self:registerAct("SoftVoice", "", {"ralsei"})
    self:registerAct("PettingX", "", {"noelle"})
end

function enemy:isXActionShort()
    return true
end

function enemy:onAct(battler, name)
    if name == "Petting" then
        self:addMercy(100)

        self.dialogue_override = self.pet_dialogue

        return string.format("* %s pet Tasque. It liked that.", battler.chara.id == "kris" and "You" or battler.chara:getName())

    elseif name == "Roar" then
        for _, enemy in ipairs(Game.battle.enemies) do
            enemy:setTired(true)
        end

        Game.battle:startActCutscene("tasque", "roar")
        return

    elseif name == "SoftVoice" then
        for _, enemy in ipairs(Game.battle.enemies) do
            if enemy.id == "tasque" then
                enemy:addMercy(100)
            elseif enemy.id == "tasque_manager" then
                enemy:addMercy(5)
            else
                enemy:addMercy(50)
            end
        end

        Game.battle:startActCutscene("tasque", "soft_voice")
        return

    elseif name == "PettingX" then
        for _, enemy in ipairs(Game.battle.enemies) do
            enemy:addMercy(100)
        end

        Game.battle:startActCutscene("tasque", "petting_x")
        return

    elseif name == "Standard" then
        self:addMercy(50)

        if battler.chara.id == "susie" then
            return "* Susie yelled at Tasque to get\noff her lawn."

        elseif battler.chara.id == "ralsei" then
            return "* Ralsei cooed gently at Tasque!"

        elseif battler.chara.id == "noelle" then
            return Utils.pick{"* Noelle got rubbed on by Tasque!", "* Tasque showed its belly to\nNoelle!"}
        end
    end

    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    return super.onAct(self, battler, name)
end

function enemy:onShortAct(battler, name)
    if name == "Petting" then
        self:addMercy(100)

        self.dialogue_override = self.pet_dialogue

        return string.format("* %s pet Tasque!", battler.chara.id == "kris" and "You" or battler.chara:getName())

    elseif name == "Standard" then
        self:addMercy(50)

        if battler.chara.id == "susie" then
            return "* Susie roared like a lion!"

        elseif battler.chara.id == "ralsei" then
            return "* Ralsei blinks at Tasque!"

        elseif battler.chara.id == "noelle" then
            if Utils.random() < 0.5 then
                return "* Noelle got rubbed on by Tasque!"
            else
                -- In Deltarune, this short act is multi-line because Noelle can't be with 3 party members.
                -- However, it does fit on one line, so let's special case it to be one-line with 3 short acts.
                if #Game.battle.short_actions < 3 then
                    return "* Tasque showed its belly to\nNoelle!"
                else
                    return "* Tasque showed its belly to Noelle!"
                end
            end
        end
    end
end

function enemy:getEncounterText()
    local text = super.getEncounterText(self)

    if text == self.text[2] then
        return string.format(text, Utils.pick{"minimized", "maximized"})
    end

    return text
end

return enemy