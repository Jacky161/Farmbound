import "code/helpers/savehelper"
import "code/global"
import "CoreLibs/object"


local REQUIRED_SERIALISATION_KEYS <const> =
{
    "state",
    "obj_data",
    "amount",
    "days",
    "days_passed",
    "type",
    "obj_string",
    "stat_id_tracked",
    "stat_id_initial_value"
}


class("ObjectiveMgr").extends()
function ObjectiveMgr:init(stats_mgr, new_obj_callback)
    self.stats_mgr = stats_mgr

    -- General info for current objective.
    self.state = nil
    self.obj_data = nil
    self.amount = nil
    self.days = nil
    self.days_passed = nil
    self.type = nil
    self.obj_string = nil

    self.stat_id_tracked = nil
    self.stat_id_initial_value = nil

    self.new_obj_callback = new_obj_callback

    self:new_objective()
end


function ObjectiveMgr:new_objective()
    -- Randomly pick a new objective to serve to the player
    self.state = Global.OBJECTIVE_STATES.STARTED
    self.obj_data = Global.OBJECTIVES[math.random(#Global.OBJECTIVES)]

    -- Randomly pick some number for the amount and time frame
    local pct = math.random(0, 100)

    self.amount = self.obj_data.min_amount + math.floor((self.obj_data.max_amount - self.obj_data.min_amount) * (pct / 100) + 0.5)
    self.days = self.obj_data.min_days + math.floor((self.obj_data.max_days - self.obj_data.min_days) * (pct / 100) + 0.5)
    self.days_passed = 0

    self.type = self.obj_data.type

    self.stat_id_tracked = nil
    self.obj_string = ""
    if self.type == Global.OBJECTIVE_TYPES.HARVEST_BASED then
        -- Pick a random crop
        local crop_data = Global.CROP_DATA[math.random(#Global.CROP_DATA)]
        self.stat_id_tracked = crop_data.harvest_stat_id
        self.obj_string = string.format(self.obj_data.string, self.amount, crop_data.name)
    elseif self.type == Global.OBJECTIVE_TYPES.SHIPPING_BASED then
        -- Pick a random shippable item
        local item_data = nil
        while self.stat_id_tracked == nil do
            item_data = Global.ITEM_DATA[math.random(#Global.ITEM_DATA)]

            if item_data.ship_quest_valid then
                self.stat_id_tracked = item_data.ship_stat_id
            end
        end
        self.obj_string = string.format(self.obj_data.string, self.amount, item_data.name)
    elseif self.type == Global.OBJECTIVE_TYPES.STAT_BASED then
        -- Randomly pick one of the valid stats that this quest can be
        self.stat_id_tracked = self.obj_data.valid_stats[math.random(#self.obj_data.valid_stats)]
        self.obj_string = string.format(self.obj_data.string, self.amount)
    end

    print("[DEBUG] Tracking stat_id = " .. self.stat_id_tracked)
    self.stat_id_initial_value = self.stats_mgr:get_stat(self.stat_id_tracked).value

    -- Debug
    print("[DEBUG] Generated new objective: " .. self.obj_string)

    if self.new_obj_callback ~= nil then
        self.new_obj_callback()
    end
end


function ObjectiveMgr:next_day()
    self.days_passed += 1

    if self:is_objective_complete() then
        self:new_objective()
        return true
    end

    return not self:is_objective_failed()
end


function ObjectiveMgr:serialise()
    return
    {
        state = self.state,
        obj_data = self.obj_data,
        amount = self.amount,
        days = self.days,
        days_passed = self.days_passed,
        type = self.type,
        obj_string = self.obj_string,
        stat_id_tracked = self.stat_id_tracked,
        stat_id_initial_value = self.stat_id_initial_value
    }
end


function ObjectiveMgr:deserialise(saved_data)
    if not SaveHelper.verify_has_keys(saved_data, REQUIRED_SERIALISATION_KEYS) then
        return false
    end

    self.state = saved_data.state
    self.obj_data = saved_data.obj_data
    self.amount = saved_data.amount
    self.days = saved_data.days
    self.days_passed = saved_data.days_passed
    self.type = saved_data.type
    self.obj_string = saved_data.obj_string
    self.stat_id_tracked = saved_data.stat_id_tracked
    self.stat_id_initial_value = saved_data.stat_id_initial_value

    return true
end


function ObjectiveMgr:get_backstory()
    return self.obj_data.backstory
end


function ObjectiveMgr:get_obj_string()
    return self.obj_string
end


function ObjectiveMgr:get_amount_cur()
    return self.stats_mgr:get_stat(self.stat_id_tracked).value - self.stat_id_initial_value
end


function ObjectiveMgr:get_amount_needed()
    return self.amount
end


function ObjectiveMgr:get_days_left()
    return self.days - self.days_passed
end


function ObjectiveMgr:is_objective_complete()
    return self:get_amount_cur() >= self:get_amount_needed()
end


function ObjectiveMgr:is_objective_failed()
    return not self:is_objective_complete() and self.days_passed >= self.days
end
