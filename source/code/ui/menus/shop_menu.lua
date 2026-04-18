import "code/ui/menus/linear_menu"
import "code/ui/menus/panels/panel_simple_text"
import "code/ui/menus/panels/panel_items_shop"
import "code/ui/menus/panels/panel_items_text"
import "CoreLibs/object"


class("ShopMenu").extends(LinearMenu)
function ShopMenu:init(bg_image, shopkeeper_name, menu_items, callback_exit, initial_selection, max_selection)
    ShopMenu.super.init(self, bg_image, 1, callback_exit)

    -- Pane 1
    self:add_panel(PanelSimpleText(shopkeeper_name, kTextAlignment.center), 1)
    local panel_items = PanelItemsShop(2, menu_items, initial_selection, max_selection)
    self:add_panel(panel_items, 1)
    self:add_panel(PanelItemsText(panel_items), 1)
end
