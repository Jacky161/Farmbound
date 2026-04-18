import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry


-- A spray effect that radiates out in the shape of a cone.
class("EffectSpray").extends(gfx.sprite)
function EffectSpray:init(x, y, arc_radius, arc_range, initial_direction, callback)
    EffectSpray.super.init(self)

    self:setBounds(x - arc_radius, y - arc_radius, 2 * arc_radius, 2 * arc_radius)
    self.arc_radius = arc_radius
    self.arc_range = arc_range
    self.percentage_timer = nil

    self.facing_direction = initial_direction
    self.arc_start_offset = 0
    self.callback = callback

    print("[DEBUG] EffectSpray initialized at (" .. self.x .. ", " .. self.y .. ")")
end


function EffectSpray:get_arc_start()
    local arc_start = 0
    if self.facing_direction == Global.DIRECTIONS.EAST then
        arc_start = 90
    elseif self.facing_direction == Global.DIRECTIONS.SOUTH then
        arc_start = 180
    elseif self.facing_direction == Global.DIRECTIONS.WEST then
        arc_start = 270
    end

    return arc_start + self.arc_start_offset
end


function EffectSpray:modify_arc_start_offset(offset)
    self.arc_start_offset += offset

    -- Constrain arc_start
    if self.arc_start_offset > 45 then
        self.arc_start_offset = 45
    end

    if self.arc_start_offset < -45 then
        self.arc_start_offset = -45
    end
end


function EffectSpray:set_direction(direction)
    if direction ~= self.facing_direction then
        self.facing_direction = direction

        if self.percentage_timer ~= nil then
            self.percentage_timer:reset()
        end
    end
end


function EffectSpray:draw(x, y, width, height)
    -- x, y coordinates are always relative to the top left ??
    local centre_x, centre_y = self.arc_radius, self.arc_radius

    local arc = geometry.arc.new(centre_x, centre_y, self.arc_radius, self:get_arc_start() - self.arc_range, self:get_arc_start() + self.arc_range)
    local arc_length = arc:length()

    -- Create line segments along the whole upper and lower triangle
    local x_bound, y_bound = self:getBounds()
    for pct = 0, 100, 5 do
        local arc_point = arc:pointOnArc(arc_length * (pct / 100))
        local segment = geometry.lineSegment.new(centre_x, centre_y, arc_point.x, arc_point.y)
        local point_end = segment:pointOnLine(segment:length() * (self.percentage_timer.value / 100) + 10)
        local point = segment:pointOnLine(segment:length() * (self.percentage_timer.value / 100))

        gfx.drawLine(point .. point_end)

        if self.callback ~= nil then
            self.callback(point.x + x_bound, point.y + y_bound)
        end
    end
end


function EffectSpray:add()
    self.percentage_timer = playdate.timer.new(500, 0, 100)
    self.percentage_timer.repeats = true
    EffectSpray.super.add(self)
end


function EffectSpray:remove()
    if self.percentage_timer ~= nil then
        self.percentage_timer:remove()
        self.percentage_timer = nil
    end
    EffectSpray.super.remove(self)
end
