import "CoreLibs/easing"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry


local ORIENTATION <const> =
{
    HORIZONTAL = 1,
    VERTICAL = 2
}
local MARGIN <const> = 5


class("EffectPowerbar").extends(gfx.sprite)
function EffectPowerbar:init(x, y, width, height, initial_fill_ratio)
    EffectPowerbar.super.init(self)

    self:setBounds((x - width / 2) - MARGIN, (y - height / 2) - MARGIN, width + MARGIN * 2, height + MARGIN * 2)
    self:moveTo(x, y)

    self.bar_width = width
    self.bar_height = height

    if self.bar_width > self.bar_height then
        -- A horizontally filling power bar (from left to right)
        self.fill_orientation = ORIENTATION.HORIZONTAL
    else
        -- A vertically filling power bar (from bottom to top)
        self.fill_orientation = ORIENTATION.VERTICAL
    end

    self.initial_fill_ratio = initial_fill_ratio
    self.fill_ratio = nil
    self:reset()
    self.indicators = {nil, nil}

    print("[DEBUG] EffectPowerbar initialized at (" .. self.x .. ", " .. self.y .. ")")
end


function EffectPowerbar:draw(x, y, width, height)
    -- x, y coordinates are always relative to the top left ??

    -- Outline
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, self.bar_width + MARGIN * 2, self.bar_height + MARGIN * 2)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0 + MARGIN, 0 + MARGIN, self.bar_width, self.bar_height)

    -- Draw the filled portion
    if self.fill_orientation == ORIENTATION.HORIZONTAL then
        gfx.fillRect(0 + MARGIN, 0 + MARGIN, self.bar_width * self.fill_ratio, self.bar_height)
    else
        local units_down = self.bar_height * (1 - self.fill_ratio)

        gfx.fillRect(0 + units_down + MARGIN, 0 + MARGIN, self.bar_width, self.bar_height - units_down)
    end

    -- Draw the little indicator arrows if needed
    for _, ratio in pairs(self.indicators) do
        local x_loc = 0 + MARGIN + self.bar_width * ratio
        local y_loc = 0 + MARGIN + self.bar_height
        gfx.setColor(gfx.kColorWhite)
        gfx.fillTriangle(x_loc, y_loc,
                        x_loc - 5, y_loc + 3,
                        x_loc + 5, y_loc + 3)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawTriangle(x_loc, y_loc,
                        x_loc - 5, y_loc + 3,
                        x_loc + 5, y_loc + 3)
    end
end


function EffectPowerbar:set_fill_ratio(fill_ratio)
    self.fill_ratio = fill_ratio
    self:constrain_fill_ratio()
end


function EffectPowerbar:set_fill_ratio_by(delta)
    self.fill_ratio += delta
    self:constrain_fill_ratio()
end


function EffectPowerbar:constrain_fill_ratio()
    if self.fill_ratio < 0 then
        self.fill_ratio = 0
    elseif self.fill_ratio > 1 then
        self.fill_ratio = 1
    end
end


function EffectPowerbar:set_indicator_arrows(left_ratio, right_ratio)
    self.indicators[1] = left_ratio
    self.indicators[2] = right_ratio
end


function EffectPowerbar:reset()
    self.fill_ratio = self.initial_fill_ratio
end


function EffectPowerbar:get_fill_ratio()
    return self.fill_ratio
end
