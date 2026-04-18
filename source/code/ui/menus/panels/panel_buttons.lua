import "code/ui/menus/panels/panel"
import "CoreLibs/graphics"
import "CoreLibs/object"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry

local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()


class("PanelButtons").extends(Panel)
function PanelButtons:init(initial_selection)
    PanelButtons.super.init(self, 30, true)

    self.selected = 0
    if initial_selection then
        self.selected = 1
    end
end


function PanelButtons:draw(x, y)
    PanelButtons.super.draw(self, x, y)

    local half_width = self:get_width() / 2

    -- Left selection
    local left_rect = geometry.rect.new(x + 15, y + 5, half_width - 30, self:get_height() - 10)
    local left_rect_text = left_rect:copy()
    left_rect_text.y += 2
    if self.selected == 0 then
        gfx.fillRoundRect(left_rect, 4)
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
    end
    gfx.drawTextInRect("No", left_rect_text, nil, nil, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    -- Right selection
    local right_rect = geometry.rect.new(x + half_width + 15, y + 5, half_width - 30, self:get_height() - 10)
    local right_rect_text = right_rect:copy()
    right_rect_text.y += 2
    if self.selected == 1 then
        gfx.fillRoundRect(right_rect, 4)
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
    end
    gfx.drawTextInRect("Yes", right_rect_text, nil, nil, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end


function PanelButtons:update(menu_instance, focused)
    if not focused then
        return
    end

    if playdate.buttonJustReleased(playdate.kButtonLeft) then
        self.selected -= 1
    elseif playdate.buttonJustReleased(playdate.kButtonRight) then
        self.selected += 1
    elseif playdate.buttonJustReleased(playdate.kButtonA) then
        menu_instance:exit(self.selected == 1)
    end

    if self.selected < 0 then
        menu_instance:pane_left()
    elseif self.selected > 1 then
        menu_instance:pane_right()
    end

    self.selected %= 2
end
