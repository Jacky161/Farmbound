import "code/global"
import "code/items/item"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics


class("Seeds").extends("Item")
function Seeds:init(crop_id)
    Seeds.super.init(self, Global.ITEM_DATA[Global.CROP_DATA[crop_id].seeds_item_id])
    self.crop_id = crop_id
end


function Seeds:use(user)
    local tile = FarmGame:get_closest_farmtile_to_player(1)

    if tile ~= nil and tile:plant(self.crop_id) then
        user:update_stamina(self:get_use_penalty())
        self:stack_remove()

        pulp.audio.playSound("item_use")
        return true
    end

    return false
end


function Seeds:get_use_penalty()
    return 0
end


function Seeds:is_usable()
    return true
end
