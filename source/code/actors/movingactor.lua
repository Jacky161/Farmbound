import "code/actors/actor"
import "code/global"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics


local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()


class("MovingActor").extends(Actor)
function MovingActor:init(x, y, images, collision_tag, initial_direction, speed, zindex)
    MovingActor.super.init(self, x, y, images[1], collision_tag, zindex)

    self.facing_direction = initial_direction
    self.speed = speed
    self.images = images

    self:set_sprite()
end


function MovingActor:set_sprite()
    local cur_north_sprite = self.images[1]
    local cur_south_sprite = self.images[2]
    local cur_east_sprite = self.images[3]

    if self.facing_direction == Global.DIRECTIONS.NORTH then
        self:setImage(cur_north_sprite, gfx.kImageUnflipped, 2)
    elseif self.facing_direction == Global.DIRECTIONS.EAST then
        self:setImage(cur_east_sprite, gfx.kImageUnflipped, 2)
    elseif self.facing_direction == Global.DIRECTIONS.SOUTH then
        self:setImage(cur_south_sprite, gfx.kImageUnflipped, 2)
    elseif self.facing_direction == Global.DIRECTIONS.WEST then
        self:setImage(cur_east_sprite, gfx.kImageFlippedX, 2)
    end

    self:setCollideRect(0, 0, self:getSize())
end


function MovingActor:move(directions)
    local new_x = self:get_x()
    local new_y = self:get_y()

    for _, direction in ipairs(directions) do
        if direction == Global.DIRECTIONS.NORTH then
            new_y -= self.speed
        elseif direction == Global.DIRECTIONS.EAST then
            new_x += self.speed
        elseif direction == Global.DIRECTIONS.SOUTH then
            new_y += self.speed
        elseif direction == Global.DIRECTIONS.WEST then
            new_x -= self.speed
        end

        self:set_facing_direction(direction)
    end

    return self:move_to_with_collisions(new_x, new_y)
end


function MovingActor:move_to_with_collisions(x, y)
    local old_x = self:get_x()
    local old_y = self:get_y()

    local result_x, result_y = self:moveWithCollisions(x, y)

    if (result_x == old_x and result_y == old_y) and (old_x ~= x and old_y ~= y) then
        -- We couldn't move and it was a diagonal movement. So we want to try only one at a time
        -- and see if that lets us move. This avoids getting "stuck" when moving diagonally.

        -- Try horizontally first
        local res_horiz = self:move_to_with_collisions(x, old_y)

        if res_horiz then
            return res_horiz
        end

        -- Try vertically next
        local res_vert = self:move_to_with_collisions(old_x, y)

        return res_vert
    end

    return (old_x ~= result_x or old_y ~= result_y)
end


function MovingActor:get_facing_direction()
    return self.facing_direction
end


function MovingActor:set_facing_direction(direction)
    self.facing_direction = direction
    self:set_sprite()
end


function MovingActor:get_speed()
    return self.speed
end


function MovingActor:set_speed(speed)
    self.speed = speed
end
