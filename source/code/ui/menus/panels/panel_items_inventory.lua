import "code/global"
import "code/ui/menus/panels/panel_items"
import "CoreLibs/object"


class("PanelItemsInventory").extends(PanelItems)
function PanelItemsInventory:get_item_image(item)
    return item:get_image()
end


function PanelItemsInventory:get_item_description(item)
    local desc_str = item:get_name()
    local sell_price = item:get_sell_price()

    if sell_price ~= nil then
        desc_str = desc_str .. " - Worth $" .. sell_price
    end

    return desc_str
end


function PanelItemsInventory:get_item_count(item)
    if item:is_stackable() then
        return item:get_stack_size()
    end

    return nil
end
