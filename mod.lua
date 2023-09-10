function Mod:init()
    local env = Kristal.Console.env

    function env.encounter(...)
        if not Game or Game.state ~= "OVERWORLD" then
            error("Can only be called in the overworld")
        end

        local map = Game.world.map

        local input = {...}
        local parsed = {}

        for i,v in ipairs(input) do
            if type(v) == "number" then
                if type(input[i-1]) == "string" then
                    for j = 1, v-1 do
                        table.insert(parsed, input[i-1])
                    end
                else
                    error("Invalid number argument ["..tostring(i).."]")
                end
            elseif type(v) == "string" then
                table.insert(parsed, v)
            else
                error("Unrecognized argument type ["..tostring(i).."]")
            end
        end

        map:setFlag("enemies", parsed)
        map:setFlag("encounter", 0)
        map:spawnEnemy()
    end

    function env.party(...)
        if not Game or Game.state ~= "OVERWORLD" then
            error("Can only be called in the overworld")
        end

        for _,chara in ipairs(Game.party) do
            Game.world:getPartyCharacter(chara):remove()
        end
        Game.world.followers = {}
        Game:setPartyMembers(...)
        Game.world:spawnParty()

        Game.world.map:spawnEnemy()
    end

    function env.run()
        if not Game or Game.state ~= "BATTLE" then
            error("Can only be called in battle")
        end

        Game.battle:returnToWorld()
    end
end

function Mod:unload()
    local env = Kristal.Console.env

    env.encounter = nil
    env.party = nil
    env.run = nil
end