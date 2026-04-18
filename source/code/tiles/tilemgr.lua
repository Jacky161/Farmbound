import "code/helpers/savehelper"
import "code/tiles/farmtile"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics
local REQUIRED_SERIALISATION_KEYS <const> =
{
    "width",
    "height",
    "tiles"
}


local function init_2d_array(width, height)
    local arr = {}
    for i = 1, width do
        arr[i] = {}
        for j = 1, height do
            arr[i][j] = nil
        end
    end

    return arr
end


class("TileMgr").extends()
function TileMgr:init(width, height)
    self.width = width
    self.height = height

    self.state = init_2d_array(width, height)
end


function TileMgr:add_tile(x, y, tile)
    self.state[x][y] = tile
end


function TileMgr:add_farmtile(x, y)
    -- need to subtract 1 because arrays are 1-based and coordinates are based on top left
    self.state[x][y] = Farmtile((x - 1) * 32, (y - 1) * 32)
end


function TileMgr:get_tile(x, y)
    if x <= 0 or y <= 0 or x >= self.width or y >= self.height then
        return nil
    end
    return self.state[x][y]
end


function TileMgr:tick_tiles()
    for _, row in pairs(self.state) do
        for _, tile in pairs(row) do
            tile:tick()
        end
    end
end


function TileMgr:serialise()
    local saved_state =
    {
        width = self.width,
        height = self.height,
        tiles = init_2d_array(self.width, self.height)
    }

    for x, row in pairs(self.state) do
        for y, tile in pairs(row) do
            saved_state.tiles[x][y] = tile:serialise()
        end
    end

    return saved_state
end


function TileMgr:deserialise(saved_data)
    if not SaveHelper.verify_has_keys(saved_data, REQUIRED_SERIALISATION_KEYS) then
        return false
    end

    for x, row in pairs(self.state) do
        for y, tile in pairs(row) do
            local result = tile:deserialise(saved_data.tiles[x][y])

            if not result then
                self:reset()
                return false
            end
        end
    end

    return true
end


function TileMgr:reset()
    for _, row in pairs(self.state) do
        for _, tile in pairs(row) do
            tile:reset()
        end
    end
end
