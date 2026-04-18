import "code/global"
import "code/ui/menus/linear_menu"
import "code/ui/menus/panels/panel_buttons"
import "code/ui/menus/panels/panel_simple_text"
import "CoreLibs/object"


class("LoadMenu").extends(LinearMenu)
function LoadMenu:init(save_time, callback_exit)
    LoadMenu.super.init(self, nil, 1, callback_exit)

    -- Pane 1
    self:add_panel(PanelSimpleText(playdate.metadata.name, kTextAlignment.center), 1)
    self:add_panel(PanelSimpleText(string.format("Found existing saved data:\n%04d-%02d-%02d at %02d:%02d:%02d", save_time.year, save_time.month, save_time.day, save_time.hour, save_time.minute, save_time.second), kTextAlignment.left), 1)
    self:add_panel(PanelSimpleText("Load this save?", kTextAlignment.center), 1)
    self:add_panel(PanelButtons(true), 1)
end
