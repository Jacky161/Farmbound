import "code/global"
import "code/items/item"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics


class("WateringCan").extends("Item")
function WateringCan:init()
    WateringCan.super.init(self, Global.ITEM_DATA[Global.ITEMS.WATERING_CAN])
end


function WateringCan:use(user)
    local tile = FarmGame:get_closest_farmtile_to_player(1)

    if tile ~= nil then
        user:update_stamina(self:get_use_penalty())
        local result = tile:water()

        if result then
            pulp.audio.playSound("item_use")
        else
            pulp.audio.playSound("item_misuse")
        end

        return result
    end

    return false
end


function WateringCan:get_use_penalty()
    return 3
end


function WateringCan:is_usable()
    return true
end
