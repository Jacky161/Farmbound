import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics

class("Tile").extends(gfx.sprite)
function Tile:init(x, y, tile_type)
    Tile.super.init(self)
    self:setCenter(0, 0)
    self:moveTo(x, y)

    self:add()
    self:setZIndex(-1)
    self:setUpdatesEnabled(false)

    self.tile_type = tile_type
end


function Tile:reset()
    -- Hook.
end


function Tile:tick()
    -- Hook.
end


function Tile:serialise()
    return
    {
        x = self.x,
        y = self.y,
        tile_type = self.tile_type
    }
end


function Tile:deserialise(saved_data)
    if saved_data == nil or self.x ~= saved_data.x or self.y ~= saved_data.y or self.tile_type ~= saved_data.tile_type then
        return false
    end
    return true
end


function Tile:get_x()
    return self.x
end


function Tile:get_y()
    return self.y
end


function Tile:get_tile_type()
    return self.tile_type
end
