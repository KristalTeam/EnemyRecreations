local Rudinn, super = Class(EnemyBattler)

function Rudinn:init()
    super.init(self)

    self.name = "Rudinn"
    self:setActor("rudinn")

    self.path = "enemies/rudinn"
    self.default = "idle"

    self.max_health = 120
    self.health = 120
    self.attack = 6
    self.defense = 0
    self.money = 30

    self.spare_points = 20

    self.waves = {
        "rudinn/diamonds_up",
        "rudinn/diamonds_aim"
    }

    self.check = "AT 6 DEF 0\nThis ambivalent diamond isn't\nany girl's best friend."

    self.text = {
        "* Rudinn is glimmering plainly.",
        "* Rudinn has no strong opinions\none way or the other.",
        "* Rudinn thinks about elaborate\nstones.",
        "* Rudinn dislikes its boss,\nbut doesn't care enough to quit.",
        "* Smells like jewelry."
    }

    self.low_health_text = "* Rudinn's luster begins to fade."

    self:registerAct("Convince")
    self:registerAct("Lecture")

    self.text_override = nil

    self.convince_next_try = 0
end

function Rudinn:isXActionShort(battler)
    return true
end

function Rudinn:onShortAct(battler, name)
    if name == "Lecture" then
        self:setAnimation("tired")
        self.setTired(true)
        print("You lectured the enemies on the\nimportance of kindness.")
        if battler.chara.id == "kris" then
            return "* You lectured the enemies on the\nimportance of kindness."
        else
            return "* " .. battler.chara:getName() .. " lectured the enemies on the\nimportance of kindness."
        end
    elseif name == "Standard" then
        self:addMercy(100)
        if battler.chara.id == "noelle" then
            return "* Noelle encouraged the enemies!"
        elseif battler.chara.id == "susie" then
            return "* Susie motivated the enemies!"
        elseif battler.chara.id == "ralsei" then
            return "* Ralsei reasoned with the enemies!"
        end
    end
    return nil
end

function Rudinn:onAct(battler, name)
    local extra_dialogue = Kristal.getLibConfig("rudinn", "extra_convince_dialogue")

    if name == "Convince" then
        if extra_dialogue then
            self:addMercy(50)
            if self.convince_next_try < 1 then
                Game.battle:startActCutscene(function(cutscene)
                    cutscene:text("* You told Rudinn to quit \nfighting.")
                    cutscene:battlerText(self, "You kidding?\nI can't quit.\nStopping you\nis my job!")
                    if Game:hasPartyMember("ralsei") then
                        cutscene:text("* Really?[wait:5]\n* What do you spend your \nmoney on?", "smile_b", "ralsei")
                        cutscene:battlerText(self, "I'm a normal\nperson.")
                        cutscene:battlerText(self, "I spend all\nmy money on\nRENT and\nMYSTIC GEMS.")
                        cutscene:text("* (Kris,[wait:5] let's try \n CONVINCING them \n again...)", "surprise_neutral", "ralsei")
                    else
                        cutscene:text("* (Perhaps you should try \nCONVINCING them \nagain...)") -- custom-made dialogue for when Ralsei isn't in the party.
                    end

                    self.convince_next_try = self.convince_next_try + 1
                end)
            else
                self.text_override = "Yeah I\nguess that\nmakes\nsense."
                return "* You told Rudinn to quit \nfighting.\n* It was utterly swayed."
            end
        else
            self:addMercy(100)
            self.text_override = "Yeah I\nguess that\nmakes\nsense."
            return "* You told Rudinn to quit \nfighting.\n* It was utterly swayed."
        end
    elseif name == "Lecture" then
        if Kristal.getLibConfig("rudinn", "tired_animation") then
            self:setAnimation("tired")
        end
        self:setTired(true)
        self.text_override = "(Yawn)...\nWhat? OK.."
        return "* You lectured Rudinn on the\nimportance of kindness.\nRudinn became [color:blue]TIRED[color:reset]..."

        --local heck = DamageNumber("damage", love.math.random(600), 200, 200, battler.actor.dmg_color)
        --self.parent:addChild(heck)
    elseif name == "Standard" then
        self:addMercy(50)
        if battler.chara.id == "noelle" then
            self.text_override = "Oh!\nIt is??"
            Game.battle:startActCutscene(function(cutscene)
                cutscene:text("* Noelle tried to give encouragement!")
                cutscene:text("* That necklace is, um...\nit's really shiny!", "smile_closed", "noelle")
            end)
        elseif battler.chara.id == "susie" then
            self.text_override = "Alright,\nalready..."
            Game.battle:startActCutscene(function(cutscene)
                cutscene:text("* Susie tried to give encouragement!")
                cutscene:text("* You! Get off your ass,\nor else!!", "teeth", "susie")
            end)
            return
        elseif battler.chara.id == "ralsei" then
            self.text_override = "Oh! I'll\ntake a\nbreak\nright now!"
            Game.battle:startActCutscene(function(cutscene)
                cutscene:text("* Ralsei tried to give encouragement!")
                cutscene:text("* Don't feel bad about taking\nbreaks every so often...\nit's perfectly normal!", "smile", "ralsei")
            end)
            return
        end
    end
    return super.onAct(self, battler, name)
end

function Rudinn:getEnemyDialogue()
    if self.text_override then
        local dialogue = self.text_override
        self.text_override = nil
        return dialogue
    end

    local dialogue
    if self.mercy >= 100 then
        dialogue = {
            "Yeah I\nguess that\nmakes\nsense.",
            "Alright,\nyou convinced\nme!!"
        }
    else
        dialogue = {
            "I'm just a\nnormal\nperson.",
            "Long live\nthe guy\nwho pays us!",
            "Shine,\nshine",
            "Face my\nDiamond\nCutter!"
        }
    end
    return dialogue[math.random(#dialogue)]
end

return Rudinn