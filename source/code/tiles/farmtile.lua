import "code/global"
import "code/tiles/tile"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics


local FARMTILE_IMAGES <const> =
{
    TILLED = gfx.image.new("images/farmtiles/tilled"),
    WATERED_OVERLAY = gfx.image.new("images/farmtiles/watered_overlay")
}


class("Farmtile").extends(Tile)
function Farmtile:init(x, y)
    Farmtile.super.init(self, x, y, Global.TILE_TYPES.tile_farm)

    self:reset()
end


function Farmtile:reset()
    self.tilled = false
    self.watered = false
    self.crop_id = 0
    self.grow_stage = 0

    self:set_sprite()
end


function Farmtile:tick()
    -- Unwatered and nothing planted becomes untilled by chance
    if self.tilled and not self.watered and self.crop_id == 0 then
        local outcome = math.random(2)

        if outcome == 2 then
            self.tilled = false
        end
    elseif self.tilled and self.watered and self.crop_id ~= 0 then
        -- A tile that is tilled, watered, and has a crop planted
        print("[DEBUG] Ticking farmtile at (" .. self.x .. ", " .. self.y .. ")")
        local crop_data = Global.CROP_DATA[self.crop_id]
        self.grow_stage = math.min(self.grow_stage + 1, crop_data.max_grow_stage)
    end

    self.watered = false
    self:set_sprite()
end


function Farmtile:serialise()
    local state = Farmtile.super.serialise(self)
    state.tilled = self.tilled
    state.watered = self.watered
    state.crop_id = self.crop_id
    state.grow_stage = self.grow_stage

    return state
end


function Farmtile:deserialise(saved_data)
    local super_result = Farmtile.super.deserialise(self, saved_data)
    if not super_result or saved_data.tilled == nil or saved_data.watered == nil or saved_data.crop_id == nil or saved_data.grow_stage == nil then
        return false
    end

    self.tilled = saved_data.tilled
    self.watered = saved_data.watered
    self.crop_id = saved_data.crop_id
    self.grow_stage = saved_data.grow_stage
    self:set_sprite()

    return true
end


function Farmtile:till()
    if self.tilled then
        return false
    end

    self.tilled = true
    self:set_sprite()
    print("[DEBUG] Tilled tile at (" .. self.x .. ", " .. self.y .. ")")

    return true
end


function Farmtile:water()
    if not self.tilled or self.watered then
        return false
    end

    self.watered = true
    self:set_sprite()
    print("[DEBUG] Watered tile at (" .. self.x .. ", " .. self.y .. ")")

    return true
end


function Farmtile:plant(crop_id)
    if not self.tilled or self.crop_id ~= 0 then
        return false
    end

    self.crop_id = crop_id
    self.grow_stage = 1
    self:set_sprite()
    print("[DEBUG] Planted crop id " .. crop_id .. " at (" .. self.x .. ", " .. self.y .. ")")

    return true
end


function Farmtile:set_sprite()
    if not self.tilled then
        self:setVisible(false)
        return
    end

    self:setVisible(true)

    if self.crop_id ~= 0 then
        -- Set corresponding to what crop it is, and the current grow stage
        self:setImage(Global.CROP_DATA[self.crop_id].tile_images[self.grow_stage])
    else
        -- Nothing planted
        self:setImage(FARMTILE_IMAGES.TILLED)
    end

    if self.watered then
        -- Draw the watered overlay on top
        local image = self:getImage():copy()

        gfx.pushContext(image)
        FARMTILE_IMAGES.WATERED_OVERLAY:draw(0, 0)
        gfx.popContext()

        self:setImage(image)
    end
end


function Farmtile:harvest()
    if self.crop_id <= 0 then
        return nil
    end

    -- If we've reached the max grow stage??
    local crop_data = Global.CROP_DATA[self.crop_id]

    if self.grow_stage < crop_data.max_grow_stage then
        return nil  -- Can't harvest == cooked
    end

    -- Can harvest
    local crop_id = self.crop_id
    self.crop_id = 0
    self.grow_stage = 0
    self:set_sprite()

    return crop_id
end
