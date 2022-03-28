function Mod:init()
    Utils.hook(Console, "createEnv", function(orig, self)
        local env = orig(self)

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
            Game.party = {}
            for _,id in ipairs{...} do
                table.insert(Game.party, Registry.getPartyMember(id))
            end
            Game.world:spawnParty()
        end

        function env.run()
            if not Game or Game.state ~= "BATTLE" then
                error("Can only be called in battle")
            end

            Game.battle:returnToWorld()
        end

        return env
    end)
end