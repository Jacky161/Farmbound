import "code/ui/menus/panels/panel"
import "CoreLibs/graphics"
import "CoreLibs/object"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry


class("PanelSimpleText").extends(Panel)
function PanelSimpleText:init(text, position, height)
    local width
    if height == nil then
        width, height = gfx.getTextSize(text)
    end
    PanelSimpleText.super.init(self, height + 5, false)
    self.fixed_height = height ~= nil

    self.text = text
    self.position = position

    if self.position == nil then
        self.position = kTextAlignment.left
    end
end


function PanelSimpleText:draw(x, y)
    -- Header
    local draw_rect = geometry.rect.new(x, y, self:get_width(), self:get_height())
    local text_rect = geometry.rect.new(x + 5, y + 5, self:get_width() - 10, self:get_height() - 5)

    Panel.fill_stroke_rect(draw_rect)
    gfx.drawTextInRect(self.text, text_rect, nil, nil, self.position)
end


function PanelSimpleText:set_text(text)
    self.text = text

    if not self.fixed_height then
        local width, height = gfx.getTextSize(text)
        self:set_height(height + 5)
    end
end
