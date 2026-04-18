import "code/ui/menus/panels/panel_simple_text"
import "CoreLibs/graphics"
import "CoreLibs/object"


local gfx <const> = playdate.graphics


class("PanelObjective").extends(PanelSimpleText)
function PanelObjective:init(obj_mgr)
    local text = obj_mgr:get_backstory() .. "\n"

    -- Goal
    text = text .. "*Goal:* " .. obj_mgr:get_obj_string() .. "\n"

    -- Progress
    text = text .. "*Progress:* " .. obj_mgr:get_amount_cur() .. "/" .. obj_mgr:get_amount_needed() .. "\n"

    -- Days remaining
    if obj_mgr:is_objective_complete() then
        text = text .. "Quest Completed! Check tomorrow\nfor next quest." .. "\n"
    else
        text = text .. "*Days Left:* " .. obj_mgr:get_days_left() .. "\n"
    end


    local width, height = gfx.getTextSize(text)

    PanelObjective.super.init(self, text, kTextAlignment.left, height)
end
