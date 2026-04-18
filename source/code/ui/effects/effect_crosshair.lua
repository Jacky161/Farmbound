import "code/global"
import "code/helpers/coordinatehelper"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry


class("EffectCrosshair").extends(gfx.sprite)
function EffectCrosshair:init(x, y, radius)
    EffectCrosshair.super.init(self)

    self:setBounds(x - radius, y - radius, 2 * radius, 2 * radius)
    self:moveTo(x, y)
    self.radius = radius
    self.bounding_arc = nil

    print("[DEBUG] EffectCrosshair initialized at (" .. self.x .. ", " .. self.y .. ")")
end


function EffectCrosshair:draw(x, y, width, height)
    -- x, y coordinates are always relative to the top left ??
    local centre_x, centre_y = self.radius, self.radius
    gfx.drawCircleAtPoint(centre_x, centre_y, self.radius)
end


function EffectCrosshair:set_bounding_arc(centre_x, centre_y, radius, direction)
    self.bounding_arc =
    {
        x = centre_x,
        y = centre_y,
        radius = radius,
        direction = direction
    }
end


function EffectCrosshair:is_inside_bounding_arc(point)
    if self.bounding_arc == nil then
        return true
    end

    local dist_sq = (((self.bounding_arc.x - point.x) * (self.bounding_arc.x - point.x)) + ((self.bounding_arc.y - point.y) * (self.bounding_arc.y - point.y)))^(.5)


    local proper_direction = true

    if self.bounding_arc.direction == Global.DIRECTIONS.NORTH then
        proper_direction = point.y >= self.bounding_arc.y
    elseif self.bounding_arc.direction == Global.DIRECTIONS.SOUTH then
        proper_direction = point.y <= self.bounding_arc.y
    elseif self.bounding_arc.direction == Global.DIRECTIONS.EAST then
        proper_direction = point.x >= self.bounding_arc.x
    elseif self.bounding_arc.direction == Global.DIRECTIONS.WEST then
        proper_direction = point.x <= self.bounding_arc.x
    end

    return self.bounding_arc.radius > (dist_sq + self.radius) and proper_direction
end


function EffectCrosshair:move_by_in_range(dx, dy)
    local new_location = geometry.point.new(self.x + dx, self.y + dy)

    if not CoordinateHelper.is_sprite_within_screen(new_location) or not self:is_inside_bounding_arc(new_location) then
        return false
    end

    self:moveBy(dx, dy)
    return true
end
