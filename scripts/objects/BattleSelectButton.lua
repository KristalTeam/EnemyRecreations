---@class BattleSelectButton : Object
---@overloadd fun(...) : BattleSelectButton
local BattleSelectButton, super = Class(Object)

function BattleSelectButton:init(chara, category, x, y)
    super.init(self, x, y, 64, 64)

    self.chara = chara
    self.category = category

    self.greyscale_fx = self:addFX(ShaderFX(Mod.greyscale_shader, {
        factor = function() return self.selected and 0 or 1 end,
        brightness = function() return self.selected and 1 or 0.5 end
    }))

    self.icon_sprite = Sprite("battleselect/unknown")

    local icon_path = "battleselect/" .. category .. "/" .. chara
    if Assets.getTexture(icon_path) then
        self.icon_sprite:setSprite(icon_path)
    end

    self.icon_sprite:addFX(MaskFX(self))

    self:addChild(self.icon_sprite)

    self.selected = false
end

function BattleSelectButton:update()
    super.update(self)

    --self.greyscale_fx.active = not self.enabled
end

function BattleSelectButton:drawMask()
    Draw.setColor(1, 1, 1)
    Draw.draw(Assets.getTexture("battleselect/option"), 0, 0, 0, 2, 2)
end

function BattleSelectButton:draw()
    Draw.setColor(Mod.BATTLER_COLORS[self.chara] or Mod.BATTLER_COLORS["unknown"])
    Draw.draw(Assets.getTexture("battleselect/option"), 0, 0, 0, 2, 2)

    super.draw(self)
end

return BattleSelectButton