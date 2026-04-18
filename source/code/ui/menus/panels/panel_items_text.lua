import "code/global"
import "code/ui/menus/panels/panel_simple_text"
import "CoreLibs/object"


class("PanelItemsText").extends(PanelSimpleText)
function PanelItemsText:init(panel_items)
    PanelItemsText.super.init(self, "", nil, 20)
    self.panel_items = panel_items
end


function PanelItemsText:update(menu_instance, focused)
    self:set_text(self.panel_items:get_selected_item_description())
end
