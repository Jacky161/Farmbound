import "code/helpers/savehelper"
import "CoreLibs/object"

local REQUIRED_SERIALISATION_KEYS <const> =
{
    "stats"
}


class("StatsMgr").extends()
function StatsMgr:init(stat_data)
    self.stats = {}

    -- Initialize stats from the data
    for _, stat in pairs(stat_data) do
        self.stats[stat.stat_id] =
        {
            value = stat.min,
            min = stat.min,
            max = stat.max,
            name = stat.name
        }
        print("[DEBUG] Initialized stat_id " .. stat.stat_id)
    end
end


function StatsMgr:update_stat(stat_id, delta)
    print("[DEBUG] Updating stat_id " .. stat_id)
    local new_val = self.stats[stat_id].value + delta

    if new_val >= self.stats[stat_id].min and new_val <= self.stats[stat_id].max then
        self.stats[stat_id].value = new_val
        return true
    end

    return false
end


function StatsMgr:get_stat(stat_id)
    return self.stats[stat_id]
end


function StatsMgr:get_num_stats()
    return #self.stats
end


function StatsMgr:serialise()
    return
    {
        stats = self.stats
    }
end


function StatsMgr:deserialise(saved_data)
    if not SaveHelper.verify_has_keys(saved_data, REQUIRED_SERIALISATION_KEYS) then
        return false
    end
    self.stats = saved_data.stats

    for _, stat in pairs(self.stats) do
        if stat.max == nil then
            stat.max = math.huge
        end
    end
    return true
end
