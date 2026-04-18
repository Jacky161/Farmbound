import "code/ui/menus/linear_menu"
import "code/ui/menus/panels/panel_simple_text"
import "code/ui/menus/panels/panel_items_inventory"
import "code/ui/menus/panels/panel_items_text"
import "CoreLibs/object"


class("ShipMenu").extends(LinearMenu)
function ShipMenu:init(bg_image, menu_items, callback_exit, initial_selection, max_selection)
    ShopMenu.super.init(self, bg_image, 1, callback_exit)

    -- Pane 1
    self:add_panel(PanelSimpleText("Shipping", kTextAlignment.center), 1)
    local panel_items = PanelItemsInventory(2, menu_items, initial_selection, max_selection)
    self:add_panel(panel_items, 1)
    self:add_panel(PanelItemsText(panel_items), 1)
end
