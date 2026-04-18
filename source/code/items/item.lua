import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics


-- class("ItemSprite").extends(gfx.sprite)
-- function ItemSprite:init()
--     ItemSprite.super.init(self)  -- this is critical
-- end


class("Item").extends()
function Item:init(item_data)
    -- self.sprite = ItemSprite()

    self.image = item_data.sprite
    self.sell_price = item_data.sell_price
    self.id = item_data.id
    self.ship_stat_id = item_data.ship_stat_id
    self.stack_size = 1

    -- if x ~= nil and y ~= nil then
    --     self:drop(x, y)
    -- end
end


-- Commonly overridden for subclasses.

function Item:use(user)
    error("Item is not usable!")
end


function Item:get_use_penalty()
    error("Item is not usable!")
end


function Item:is_usable()
    return false
end


-- This is only run when the item is equipped
function Item:update(user)
    -- Hook
end


function Item:on_equip(user)
    -- Hook
end


function Item:on_unequip(user)
    -- Hook
end


function Item:can_player_move()
    return true
end


-- The following could be overridden but you probably don't have to.


function Item:get_image()
    return self.image
end


function Item:get_name()
    return Global.ITEM_DATA[self.id].name
end


function Item:get_id()
    return self.id
end


function Item:get_ship_stat_id()
    return self.ship_stat_id
end


function Item:get_sell_price()
    return self.sell_price
end


function Item:is_stackable()
    return Global.ITEM_DATA[self.id].max_stack_size ~= 1
end


function Item:is_stack_space_available()
    return Global.ITEM_DATA[self.id].max_stack_size > self.stack_size
end


function Item:is_stack_empty()
    return self.stack_size == 0
end


function Item:get_stack_size()
    return self.stack_size
end


function Item:stack_add()
    if self:is_stack_space_available() then
        self.stack_size += 1
    end

    return self.stack_size
end


function Item:stack_remove()
    self.stack_size -= 1

    if self.stack_size < 0 then
        self.stack_size = 0
    end

    return self.stack_size
end


-- function Item:drop(x, y)
--     self.sprite:moveTo(x, y)
--     self.sprite:setImage(self:get_image())
--     self.sprite:setCollideRect(0, 0, self.sprite:getSize())
--     self.sprite:add()
-- end
