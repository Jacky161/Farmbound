import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry


local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()

local EMOTEBOX_RECT <const> = geometry.rect.new(0, 0, 25, 25)
local EMOTEBOX_RECT_TEXT <const> = geometry.rect.new(0, 4, 25, 25)


local function fill_stroke_rect(rect)
    local prev_colour = gfx.getColor()

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(rect)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(rect)

    gfx.setColor(prev_colour)
end


class("Emotebox").extends(gfx.sprite)
function Emotebox:init(actor, character, zindex)
    Emotebox.super.init(self)

    self.actor = actor
    self.character = character

    local x = actor:get_x()
    local y = actor:get_y() - actor:get_height()

    self:setBounds(x - EMOTEBOX_RECT.width / 2, y - EMOTEBOX_RECT.height, EMOTEBOX_RECT.width, EMOTEBOX_RECT.height)
    self:setZIndex(zindex)
    self:moveTo(x, y)
    self:add()
end


function Emotebox:draw(x, y, width, height)
    fill_stroke_rect(EMOTEBOX_RECT)

    gfx.drawTextInRect(self.character, EMOTEBOX_RECT_TEXT, nil, nil, kTextAlignment.center)
end


function Emotebox:update()
    self:moveTo(self.actor:get_x(), self.actor:get_y() - self.actor:get_height())
end
