import "code/global"
import "code/ui/menus/linear_menu"
import "code/ui/menus/panels/panel_simple_text"
import "CoreLibs/object"


class("LoadFailMenu").extends(LinearMenu)
function LoadFailMenu:init()
    LoadFailMenu.super.init(self, nil, 1, nil)

    -- Pane 1
    self:add_panel(PanelSimpleText(":(", kTextAlignment.center), 1)
    self:add_panel(PanelSimpleText("Save data is corrupted.\nPlease restart the game.", kTextAlignment.center), 1)
end
