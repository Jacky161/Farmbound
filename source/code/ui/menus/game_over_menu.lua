import "code/global"
import "code/ui/menus/linear_menu"
import "code/ui/menus/panels/panel_items_inventory"
import "code/ui/menus/panels/panel_items_text"
import "code/ui/menus/panels/panel_objective"
import "code/ui/menus/panels/panel_simple_text"
import "code/ui/menus/panels/panel_stats"
import "CoreLibs/object"


class("GameOverMenu").extends(LinearMenu)
function GameOverMenu:init(bg_image, callback_exit)
    GameOverMenu.super.init(self, bg_image, 4, callback_exit, {true, false, false, false}, {playdate.kButtonA})

    -- Pane 1
    self:add_panel(PanelSimpleText("Game Over!", kTextAlignment.center), 1)
    self:add_panel(PanelSimpleText("The objective was:", kTextAlignment.left), 1)
    self:add_panel(PanelObjective(FarmGame:get_obj_mgr()), 1)
    self:add_panel(PanelSimpleText("Press Right to View Stats.\nPress A to Reset.", kTextAlignment.left), 1)

    -- Pane 2 - General Stats
    self:add_panel(PanelSimpleText("General Stats", kTextAlignment.center), 2)
    self:add_panel(PanelStats(FarmGame:get_stats_mgr(), 1, Global.STATS_META.last_manual_stat), 2)

    -- Pane 3 - Harvest Stats
    self:add_panel(PanelSimpleText("Harvest Stats", kTextAlignment.center), 3)
    self:add_panel(PanelStats(FarmGame:get_stats_mgr(), Global.STATS_META.last_manual_stat + 1, Global.STATS_META.last_harvest_stat), 3)

    -- Pane 4 - Shipping Stats
    self:add_panel(PanelSimpleText("Shipping Stats", kTextAlignment.center), 4)
    self:add_panel(PanelStats(FarmGame:get_stats_mgr(), Global.STATS_META.last_harvest_stat + 1), 4)
end
