import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/string"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry
local UUID <const> = playdate.string.UUID
local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()



class("DrawHelper").extends(gfx.sprite)
function DrawHelper:init(width, height)
    DrawHelper.super.init(self)  -- this is critical
    self.callbacks = {}

    self:setBounds(0, 0, width, height)
    self:setUpdatesEnabled(false)
    self:setZIndex(-1)
end


function DrawHelper:set_draw_func(key, draw_func)
    self.callbacks[key] = draw_func
end


function DrawHelper:remove_draw_func(key)
    self.callbacks[key] = nil
end


function DrawHelper:clear()
    self.callbacks = {}
end


function DrawHelper.gen_key()
    return UUID(32)
end


function DrawHelper:draw(x, y, width, height)
    for _, draw_func in pairs(self.callbacks) do
        draw_func()
    end
end
