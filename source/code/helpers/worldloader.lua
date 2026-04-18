--[[
BSD Zero Clause License
=======================

Copyright (C) Panic Inc. help@play.date
Copyright (C) 2026 Jacky161

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
]]

-- helper class for loading game data from a Tiled JSON file
import "CoreLibs/object"


-- loads the json file and returns a lua table containing the data
local function getJSONTableFromTiledFile(path)
    local jsonTable = json.decodeFile(path)

    if not jsonTable then
        print('ERROR PARSING JSON DATA for ' .. path)
        return nil
    end

    return jsonTable

end

-- returns an array containing the tilesets from the json file
local function getTilesetsFromJSON(jsonTable)

    local tilesets = {}

    for i=1, #jsonTable.tilesets do

        local tileset = jsonTable.tilesets[i]
        local newTileset = {}

        newTileset.firstgid = tileset.firstgid
        newTileset.lastgid = tileset.firstgid + tileset.tilecount - 1
        newTileset.name = tileset.name
        newTileset.tileHeight = tileset.tileheight
        newTileset.tileWidth = tileset.tilewidth
        local tilesetImageName = string.sub(tileset.image, 1, string.find(tileset.image, '-table-') - 1)

        newTileset.imageTable = playdate.graphics.imagetable.new(tilesetImageName)

        tilesets[i] = newTileset

    end

    return tilesets
end


-- utility function for importTilemapsFromTiledJSON()
local function tilesetWithName(tilesets, name)
    for _, tileset in pairs(tilesets) do
        if tileset.name == name then
            return tileset
        end
    end

    print("[ERROR] Couldn't find tileset for '" .. name .. "'")
    return nil

end


local function getProperty(properties, name)
    for key, property in ipairs(properties) do
        if property.name == name then
            return property.value
        end
    end
    return nil
end


local function getProperties(properties)
    local property_table = {}

    for key, property in ipairs(properties) do
        property_table[property.name] = property.value
    end

    return property_table
end


local function addLayers(dataset, layers, object_layers, tilesets)
    for i=1, #dataset.layers do

        local level = {}

        local layer = dataset.layers[i]

        if layer.type == "group" then
            -- Recursively add all the layers in this group
            addLayers(layer, layers, object_layers, tilesets)
            goto continue
        end

        if layer.type == "objectgroup" then
            for j, object in ipairs(layer.objects) do
                object_layers[object.name] = object
            end
            goto continue
        end

        level.name = layer.name
        level.x = layer.x
        level.y = layer.y
        level.tileHeight = layer.height
        level.tileWidth = layer.width

        local tileset = nil
        print("[DEBUG] Processing tilemap: " .. level.name)
        local tilesetName = getProperty(layer.properties, "tileset")
        local property_table = getProperties(layer.properties)

        if tilesetName ~= nil then
            tileset = tilesetWithName(tilesets, tilesetName)
        end

        if tileset ~= nil then
            level.pixelHeight = level.tileHeight * tileset.tileHeight
            level.pixelWidth = level.tileWidth * tileset.tileWidth
            level.properties = property_table

            local tilemap = playdate.graphics.tilemap.new()

            if tileset.imageTable == nil then
                error("[ERROR] Failed to load imageTable for " .. level.name)
            end
            tilemap:setImageTable(tileset.imageTable)
            tilemap:setSize(level.tileWidth, level.tileHeight)

            -- we want our indexes for each tileset to be 1-based, so remove the offset that Tiled adds.
            -- this is only makes sense because because we have exactly one tilemap image per layer
            local indexModifier = tileset.firstgid-1

            local tileData = layer.data

            local x = 1
            local y = 1

            for j=1, #tileData do

                local tileIndex = tileData[j]

                -- if level.name == "TownPaths" then
                --     print("[DEBUG] Checking tile number " .. j .. " at (" .. x .. ", " .. y .. ") with tileIndex " .. tileIndex)
                -- end

                if tileIndex < 0 then
                    print("[WARN] tileIndex at (" .. x .. ", " .. y .. ") = " .. tileIndex .. " which may be invalid.")
                end

                if tileIndex > 0 then
                    tileIndex = tileIndex - indexModifier

                    tilemap:setTileAtPosition(x, y, tileIndex)

                    -- if level.name == "TownPaths" then
                    --     print("[DEBUG] Setting tilemap at (" .. x .. ", " .. y .. ") to " .. tileIndex)
                    -- end
                end

                x = x + 1
                if ( x > level.tileWidth-1 ) then
                    x = 0
                    y = y + 1
                end
            end

            level.tilemap = tilemap
            layers[layer.name] = level
        end
        ::continue::
    end
end


class("WorldLoader").extends()

-- loads the data we are interested in from the Tiled json file
-- returns custom layer tables containing the data, which are basically a subset of the layer objects found in the Tiled file
function WorldLoader.importTilemapsFromTiledJSON(path)

    local jsonTable = getJSONTableFromTiledFile(path)

    if jsonTable == nil then
        return
    end


    -- load tilesets
    local tilesets = getTilesetsFromJSON(jsonTable)


    -- create tilemaps from the level data and already-loaded tilesets

    local layers = {}
    local object_layers = {}

    addLayers(jsonTable, layers, object_layers, tilesets)

    return layers, object_layers

end
