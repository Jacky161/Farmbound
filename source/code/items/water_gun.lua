import "code/global"
import "code/items/item"
import "code/ui/effects/effect_spray"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics


class("WaterGun").extends("Item")
function WaterGun:init()
    WaterGun.super.init(self, Global.ITEM_DATA[Global.ITEMS.WATER_GUN])

    self.on = false
    self.effect_spray = EffectSpray(0, 0, 75, 15, Global.DIRECTIONS.EAST, function (x, y)
        local tile = FarmGame:get_closest_tile(x, y, nil, nil, Global.TILE_TYPES.tile_farm)

        if tile ~= nil then
            tile:water()
        end
    end)
    self.stamina_drain_timer = nil
end


function WaterGun:use(user)
    self.on = not self.on
    self:update_state(user)
    return true
end


function WaterGun:update_state(user)
    if self.on then
        -- Turn on the spray effect
        if self.stamina_drain_timer == nil then
            self.stamina_drain_timer = playdate.timer.new(1000, function ()
                user:update_stamina(self:get_use_penalty())
            end)
            self.stamina_drain_timer.repeats = true
        end

        self.effect_spray:add()
        pulp.audio.playSong("water_gun")
    else
        if self.stamina_drain_timer ~= nil then
            self.stamina_drain_timer:remove()
            self.stamina_drain_timer = nil
        end
        self.effect_spray:remove()
        pulp.audio.stopSong()
    end
end


function WaterGun:get_use_penalty()
    return 3
end


function WaterGun:update(user)
    if not self.on then
        return
    end

    self.effect_spray:moveTo(FarmGame:get_player_x(), FarmGame:get_player_y())
    self.effect_spray:set_direction(FarmGame:get_player_facing_direction())

    -- Move with the crank!!!
    local crank_change_degrees = playdate.getCrankChange()
    self.effect_spray:modify_arc_start_offset(crank_change_degrees)
end


function WaterGun:is_usable()
    return true
end


function WaterGun:on_unequip(user)
    self.on = false
    self:update_state()
end
