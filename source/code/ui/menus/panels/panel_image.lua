import "code/ui/menus/panels/panel"
import "CoreLibs/graphics"
import "CoreLibs/object"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry
local PADDING <const> = 5


class("PanelImage").extends(Panel)
function PanelImage:init(img)
    local width, height = img:getSize()
    PanelImage.super.init(self, height + PADDING * 2, false)
    self.img = img
end


function PanelImage:draw(x, y)
    PanelImage.super.draw(self, x, y)

    --
    self.img:drawCentered(x + self:get_width() / 2, y + self:get_height() / 2)
end
