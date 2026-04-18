
import "CoreLibs/graphics"
import "CoreLibs/object"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry
local PANEL_WIDTH <const> = 300


-- Panel is abstract.
class("Panel").extends()
function Panel:init(height, focusable)
    self.height = height
    self.focusable = focusable
end


function Panel.fill_stroke_rect(rect)
    local prev_colour = gfx.getColor()

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(rect)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(rect)

    gfx.setColor(prev_colour)
end


function Panel:draw(x, y)
    local draw_rect = geometry.rect.new(x, y, PANEL_WIDTH, self.height)
    Panel.fill_stroke_rect(draw_rect)
end


function Panel:get_width()
    return PANEL_WIDTH
end


function Panel:get_height()
    return self.height
end


function Panel:set_height(height)
    self.height = height
end


function Panel:update(menu_instance, focused)

end


function Panel:is_focusable()
    return self.focusable
end
