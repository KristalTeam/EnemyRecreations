return {
    cook_ralsei = function(cutscene)
        for _,battler in ipairs(Game.battle.party) do
            battler:heal(30)
        end
        cutscene:text("* Ralsei cooked up a cure.")
        cutscene:text("* If you're sick,\nshouldn't you have some\nsoup? Say \"aah\"~!", "blush_pleased", "ralsei")
        cutscene:text("* Sickness was cured! Everyone's\nHP up!")
    end,

    cook_susie = function(cutscene, battler, enemy)
        cutscene:text("* Susie cooked up a cure!")
        cutscene:text("* What, you want me to\ncook something!?", "smile", "susie")
        cutscene:text("* Susie put a hot dog in the\nmicrowave!")
        if false then
            local susie = cutscene:getCharacter("susie")
            local explosion = susie:explode(0, 0, true)
            explosion:setScale(1)
            explosion.speed = 1
            explosion:setOrigin(0.5, 0.75)
        else
            enemy:explode(0, 0, true)
        end
        enemy:hurt(enemy.health * 0.75, battler)
        cutscene:text("* She forgot to poke holes in it!\nThe hot dog exploded!")
    end
}