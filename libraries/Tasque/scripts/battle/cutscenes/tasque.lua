return {
    roar = function(cutscene, battler, enemy)
        cutscene:text("* Susie roared!! The enemies became TIRED.")

        if not enemy.acted_susie then
            cutscene:text("* Who's king of the jungle now!?[react:1]", "smile", "susie", {reactions = {
                    {"It's just a cat...", "right", "middle", "surprise_neutral", "ralsei"}
            }})

            enemy.acted_susie = true
        end
    end,

    soft_voice = function(cutscene, battler, enemy)
        cutscene:text("* Ralsei talked in a soft voice\nto the enemies!")

        if not enemy.acted_ralsei then
            cutscene:text("* There,[wait:5] there,[wait:5] it's okay,[wait:5]\nlittle kitty...[react:1]", "blush_smile", "ralsei", {reactions = {
                {"Isn't that just how he normally talks?", "middle", "bottom", "sus_nervous", "susie"}
            }})

            enemy.acted_ralsei = true
        end
    end,

    petting_x = function(cutscene, battler, enemy)
        cutscene:text("* You and Noelle pet the enemies!")

        if not enemy.acted_noelle then
            cutscene:text("* Th-there,[wait:5] there...[wait:5] (It's\nnot too different from\nCatti...)", "smile_closed", "noelle")

            enemy.acted_noelle = true
        end
    end
}