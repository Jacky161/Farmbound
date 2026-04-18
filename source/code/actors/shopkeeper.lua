import "code/actors/npc"
import "code/global"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics


local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()
local REQUIRED_SERIALISATION_KEYS <const> =
{
    "selling_inventory"
}


class("Shopkeeper").extends(NPC)
function Shopkeeper:init(shopkeeper_data, shopkeeper_idx, x, y)
    Shopkeeper.super.init(self, shopkeeper_data, x, y)

    self.selling_inventory = nil
    self.shopkeeper_idx = shopkeeper_idx
    self:reset()
end

function Shopkeeper:reset()
    self.selling_inventory = {}
    for i, item in ipairs(Global.SHOPKEEPER_DATA[self.shopkeeper_idx].selling) do
        self.selling_inventory[i] = {id = item.id, quantity = item.quantity}
    end
end

function Shopkeeper:serialise()
    return {selling_inventory = self.selling_inventory}
end


function Shopkeeper:deserialise(saved_data)
    if not SaveHelper.verify_has_keys(saved_data, REQUIRED_SERIALISATION_KEYS) then
        return false
    end
    self.selling_inventory = saved_data.selling_inventory
    return true
end


function Shopkeeper:get_selling_inventory()
    return self.selling_inventory
end


function Shopkeeper:interact(game)
    game:switch_state(Global.STATES.MENU_SHOP, self)
end
