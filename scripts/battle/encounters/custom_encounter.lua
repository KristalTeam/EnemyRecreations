local encounter, super = Class(Encounter, "custom_encounter")

function encounter:onBattleEnd()
    Game.battle:setState("NONE")

    Game.fader:fadeOut(nil, {speed = 0.5})

    Game.stage.timer:after(0.8, function()
        Game.battle:returnToWorld()

        Game.fader:fadeIn(nil, {speed = 0})

        Game.state = "BATTLESELECT"
        Mod.battle_select:setState("INTRO")
    end)

    for _,party in ipairs(Game.party) do
        party:heal(math.huge, false)
    end
end

return encounter