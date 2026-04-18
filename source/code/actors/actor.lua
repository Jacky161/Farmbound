import "code/actors/emotebox"
import "code/global"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics


local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()


class("Actor").extends(gfx.sprite)
function Actor:init(x, y, image, collision_tag, zindex)
    Actor.super.init(self)

    self:setImage(image:scaledImage(2))
    self:setCollideRect(0, 0, self:getSize())
    self:setTag(collision_tag)
    self:setZIndex(zindex)
    self:moveTo(x, y)
    self:add()
end


function Actor:reset()
    -- Subclasses implement
end


function Actor:serialise()
    -- Subclasses implement
    return nil
end


function Actor:deserialise(saved_data)
    -- Subclasses implement
    return true
end


function Actor:colliding_with(collision_tag)
    local collisions = self:overlappingSprites()

    for _, sprite in ipairs(collisions) do
        if sprite:getTag() == collision_tag then
            return sprite
        end
    end

    return nil
end


function Actor:get_x()
    return self.x
end


function Actor:get_y()
    return self.y
end


function Actor:get_width()
    return self.width
end


function Actor:get_height()
    return self.height
end


function Actor:set_collision_response(collision_response)
    self.collisionResponse = collision_response
end


function Actor:emote(character)
    -- Display an emote box at the top of the actor with the character inside
    self:unemote()
    self.emote_sprite = Emotebox(self, character, self:getZIndex())
    self.emote_sprite:add()
end


function Actor:unemote()
    if self.emote_sprite ~= nil then
        self.emote_sprite:remove()
        self.emote_sprite = nil
    end
end
