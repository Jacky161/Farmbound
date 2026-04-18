import "code/actors/actor"
import "code/global"
import "code/ui/textbox"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics


local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()


class("NPC").extends(Actor)
function NPC:init(npc_data, x, y)
    NPC.super.init(self, x, y, npc_data.sprite, Global.COLLISION_TAGS.NPC, -1)

    self.name = npc_data.name
    self.dialogue = npc_data.dialogue
end


function NPC:get_name()
    return self.name
end


function NPC:set_dialogue(dialogue)
    self.dialogue = dialogue
end


function NPC:interact(game)
    game:set_paused(true)

    -- Create a new textbox and show their dialogue
    local textbox = Textbox(self.dialogue, function ()
        game:set_paused(false)
    end)
    textbox:add()
end
