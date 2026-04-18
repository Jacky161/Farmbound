import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics


local BOBBER_IMAGE <const> = gfx.image.new("images/bobber")


class("Bobber").extends(gfx.sprite)
function Bobber:init(x, y)
    Bobber.super.init(self)

    self:setImage(BOBBER_IMAGE)
    self:moveTo(x, y)
end
