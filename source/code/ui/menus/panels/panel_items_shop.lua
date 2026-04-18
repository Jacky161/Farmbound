import "code/global"
import "code/ui/menus/panels/panel_items"
import "CoreLibs/object"


class("PanelItemsShop").extends(PanelItems)
function PanelItemsShop:get_item_image(item)
    return Global.ITEM_DATA[item.id].sprite
end


function PanelItemsShop:get_item_description(item)
    return Global.ITEM_DATA[item.id].name .. " - $" .. Global.ITEM_DATA[item.id].purchase_price
end


function PanelItemsShop:get_item_count(item)
    return item.quantity
end
