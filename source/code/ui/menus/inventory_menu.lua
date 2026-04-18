import "code/global"
import "code/ui/menus/linear_menu"
import "code/ui/menus/panels/panel_items_inventory"
import "code/ui/menus/panels/panel_items_text"
import "code/ui/menus/panels/panel_objective"
import "code/ui/menus/panels/panel_simple_text"
import "code/ui/menus/panels/panel_stats"
import "CoreLibs/object"


class("InventoryMenu").extends(LinearMenu)
function InventoryMenu:init(bg_image, menu_items, callback_exit, initial_selection, max_selection)
    InventoryMenu.super.init(self, bg_image, 5, callback_exit)

    -- Pane 1
    self:add_panel(PanelSimpleText("Inventory", kTextAlignment.center), 1)
    local panel_items = PanelItemsInventory(2, menu_items, initial_selection, max_selection)
    self:add_panel(panel_items, 1)
    self:add_panel(PanelItemsText(panel_items), 1)

    -- Pane 2
    self:add_panel(PanelSimpleText("Objective", kTextAlignment.center), 2)
    self:add_panel(PanelObjective(FarmGame:get_obj_mgr()), 2)

    -- Pane 3 - General Stats
    self:add_panel(PanelSimpleText("General Stats", kTextAlignment.center), 3)
    self:add_panel(PanelStats(FarmGame:get_stats_mgr(), 1, Global.STATS_META.last_manual_stat), 3)

    -- Pane 4 - Harvest Stats
    self:add_panel(PanelSimpleText("Harvest Stats", kTextAlignment.center), 4)
    self:add_panel(PanelStats(FarmGame:get_stats_mgr(), Global.STATS_META.last_manual_stat + 1, Global.STATS_META.last_harvest_stat), 4)

    -- Pane 5 - Shipping Stats
    self:add_panel(PanelSimpleText("Shipping Stats", kTextAlignment.center), 5)
    self:add_panel(PanelStats(FarmGame:get_stats_mgr(), Global.STATS_META.last_harvest_stat + 1), 5)
end
