import "CoreLibs/graphics"
import "CoreLibs/object"


local gfx <const> = playdate.graphics
local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()


class("CoordinateHelper").extends()

function CoordinateHelper.sprite_to_screen(point)
    local dx, dy = gfx.getClipRect()
    return point:offsetBy(-dx, -dy)
end


function CoordinateHelper.screen_to_sprite(point)
    local dx, dy = gfx.getClipRect()
    return point:offsetBy(dx, dy)
end


function CoordinateHelper.is_sprite_within_screen(point)
    local screen_coords = CoordinateHelper.sprite_to_screen(point)
    return screen_coords.x <= DISPLAY_WIDTH and screen_coords.x >= 0 and screen_coords.y <= DISPLAY_HEIGHT and screen_coords.y >= 0
end
