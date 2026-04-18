import "code/ui/menus/panels/panel_simple_text"
import "CoreLibs/graphics"
import "CoreLibs/object"


local gfx <const> = playdate.graphics


class("PanelStats").extends(PanelSimpleText)
function PanelStats:init(stats_mgr, stat_idx_start, stat_idx_stop)
    local text = ""

    if stat_idx_stop == nil then
        stat_idx_stop = stats_mgr:get_num_stats()
    end

    for i = stat_idx_start, stat_idx_stop do
        local stat = stats_mgr:get_stat(i)
        text = text .. stat.name .. ": " .. stat.value .. "\n"
    end

    PanelStats.super.init(self, text, kTextAlignment.left)
end
