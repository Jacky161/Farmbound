import "code/global"
import "code/items/fishing_rod"
import "code/items/hoe"
import "code/items/item"
import "code/items/seeds"
import "code/items/water_gun"
import "code/items/watering_can"
import "CoreLibs/object"


class("ItemFactory").extends()
function ItemFactory.new_item(item_id)
    if item_id == Global.ITEMS.FISHING_ROD then
        return FishingRod()
    elseif item_id == Global.ITEMS.HOE then
        return Hoe()
    elseif item_id == Global.ITEMS.WATERING_CAN then
        return WateringCan()
    elseif item_id == Global.ITEMS.WATER_GUN then
        return WaterGun()

    -- Seeds
    elseif item_id == Global.ITEMS.CARROT_SEEDS then
        return Seeds(Global.CROPS.CARROTS)
    elseif item_id == Global.ITEMS.POTATO_SEEDS then
        return Seeds(Global.CROPS.POTATOES)
    elseif item_id == Global.ITEMS.CORN_SEEDS then
        return Seeds(Global.CROPS.CORN)
    elseif item_id == Global.ITEMS.STRAWBERRY_SEEDS then
        return Seeds(Global.CROPS.STRAWBERRIES)

    else
        -- Generic item fallback. Works for items with no use behaviour
        return Item(Global.ITEM_DATA[item_id])
    end

    error("ItemFactory.new_item received invalid item id = " .. item_id)
end
