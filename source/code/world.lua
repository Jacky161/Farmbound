import "code/tiles/tilemgr"
import "code/tiles/farmtile"
import "code/tiles/tile"
import "code/helpers/worldloader"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics
local LEVEL <const> = "worlds/farm.json"
local TILE_SIZE <const> = 32


class("World").extends(gfx.sprite)
function World:init()
    World.super.init(self)

    self.layers = nil
    self.object_layers = nil
    self.game_tiles = nil
    self.loading_zones = nil
    self.tilemgr = nil

    self:load_layers()
    self:setup_tiles()
    self:setZIndex(-1)  -- So we appear behind other sprites
    self:add()
end


function World:reset()
    self.tilemgr:reset()
end


function World:get_closest_tile(x, y, x_offset, y_offset, type)
    local tile_x = math.floor(x / 32) + 1 + x_offset
    local tile_y = math.floor(y / 32) + 1 + y_offset

    local tile = self.tilemgr:get_tile(tile_x, tile_y)

    if tile ~= nil and type ~= nil then
        if tile:get_tile_type() == type then
            return tile
        end

        return nil
    end

    return tile
end


function World:get_tilemgr()
    return self.tilemgr
end


function World:get_poi(name)
    return self.object_layers[name].x, self.object_layers[name].y
end


function World:get_loading_zones()
    return self.loading_zones
end


function World:load_layers()
    self.layers, self.object_layers = WorldLoader.importTilemapsFromTiledJSON(LEVEL)
    self.game_tiles = {}
    self.loading_zones = {}

    local max_bounds_width = 0
    local max_bounds_height = 0

    for _, layer in pairs(self.layers) do
        max_bounds_width = math.max(max_bounds_width, layer.pixelWidth)
        max_bounds_height = math.max(max_bounds_height, layer.pixelHeight)

        -- Collision flag tells us if that whole layer should be collidable
        if layer.properties["collision"] == true then
            gfx.sprite.addWallSprites(layer.tilemap, {})
        end

        if string.find(layer.properties["type"], "tile_") == 1 then
            -- This is a special one
            table.insert(self.game_tiles, layer)
        elseif layer.properties["type"] == "lz" then
            -- Loading zones
            local x, y = self:get_poi(layer.properties["lz_poi"])
            print("[DEBUG] Adding lz tag #" .. layer.properties["collision_tag"] .. " -> (" .. x .. ", " .. y .. ")")
            self.loading_zones[layer.properties["collision_tag"]] = {
                x = x,
                y = y,
                active_hour_start = layer.properties["active_hour_start"],  -- both these could be nil if N/A
                active_hour_end = layer.properties["active_hour_end"]
            }
        end

        if layer.properties["collision_tag"] ~= 0 then
            print("[DEBUG] When building world, found collision_tag = " .. layer.properties["collision_tag"])

            -- Create sprites that correspond to each of the tiles and assign them the given tag
            self:setup_tilemap_sprites(layer.tilemap, layer.properties["collision_tag"])
        end
    end

    self:setBounds(0, 0, max_bounds_width, max_bounds_height)
end


function World:setup_tilemap_sprites(tilemap, collision_tag)
	local width, height = tilemap:getSize()

	local x = 0
	local y = 0

	for row = 1, height do
		local column = 1
		while column <= width do

			local gid = tilemap:getTileAtPosition(column, row)

			if gid ~= nil and gid > 0 then

				local startX = x
				local cellWidth = TILE_SIZE

                local w = gfx.sprite.new()
                w:setUpdatesEnabled(false) -- remove from update cycle
                w:setVisible(false) -- invisible sprites can still collide
                w:setCenter(0,0)
                w:setBounds(startX, y, cellWidth, TILE_SIZE)
                w:setCollideRect(0, 0, cellWidth, TILE_SIZE)
                w:setTag(collision_tag)

                w:addSprite()
                w.gid = gid
                w.column = column
                w.row = row
			end
			x += TILE_SIZE
			column += 1

		end

		x = 0
		y = y + TILE_SIZE
	end
end


function World:setup_tiles()
    for _, layer in ipairs(self.game_tiles) do
        local tilemap = layer.tilemap
        local tiles_width, tiles_height = tilemap:getSize()

        if self.tilemgr == nil then
            self.tilemgr = TileMgr(tiles_width, tiles_height)
        end

        for x = 1, tiles_width do
            for y = 1, tiles_height do
                local gid = tilemap:getTileAtPosition(x, y)

                if gid ~= nil and gid == 1 then
                    -- This is a tile
                    if layer.properties["type"] == "tile_farm" then
                        -- need to subtract 1 because arrays are 1-based and coordinates are based on top left
                        self.tilemgr:add_tile(x, y, Farmtile((x - 1) * 32, (y - 1) * 32))
                    else
                        self.tilemgr:add_tile(x, y, Tile((x - 1) * 32, (y - 1) * 32, Global.TILE_TYPES[layer.properties["type"]]))
                    end
                end
            end
        end
    end
end


function World:serialise()
    return self.tilemgr:serialise()
end


function World:deserialise(saved_data)
    return self.tilemgr:deserialise(saved_data)
end


--! Sprite library callbacks


function World:draw(x, y, width, height)
    for _, layer in pairs(self.layers) do
        if layer.properties["visible"] == true then
            layer.tilemap:draw(0, 0)
        end
    end

    for _, point in ipairs(DebugDrawingPoints) do
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(point[1], point[2], 11)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawCircleAtPoint(point[1], point[2], 10)
    end
end
