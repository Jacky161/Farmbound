import "code/actors/movingactor"
import "code/global"
import "code/helpers/savehelper"
import "code/items/item_factory"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics

local PLAYER_IMAGES <const> =
{
    gfx.image.new("images/playerBackward"),
    gfx.image.new("images/playerForward"),
    gfx.image.new("images/playerRight")
}


local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()
local COLLISION_RESPONSE <const> = Global.COLLISION_RESPONSE  -- caching?
local REQUIRED_SERIALISATION_KEYS <const> =
{
    "item_ids",
    "inventory_capacity",
    "cur_item_idx",
    "stamina",
    "stamina_max",
    "running_stamina",
    "running_stamina_max",
    "run",
    "facing_direction",
    "x",
    "y"
}
local RUN_STAMINA_REV_RATIO <const> = 360 * 5  -- How many full rotations to increase from 0 to max stamina


local function playerCollisionResponse(self, other)
    local other_tag = other:getTag()

    return COLLISION_RESPONSE[other_tag + 1]
end


class("Player").extends(MovingActor)
function Player:init(x, y)
    Player.super.init(self, x, y, PLAYER_IMAGES, Global.COLLISION_TAGS.PLAYER, Global.DIRECTIONS.SOUTH, 3, 0)

    self.default_speed = 3
    self.running_multiplier = 1.5
    self:reset()
    self:set_collision_response(playerCollisionResponse)
end


function Player:reset()
    self.inventory = {}
    self.inventory_capacity = 12
    self.cur_item_idx = 1
    self.stamina = 100
    self.stamina_max = 100
    self.running_stamina = 150
    self.running_stamina_max = 150
    self.run = false
    self:set_facing_direction(Global.DIRECTIONS.SOUTH)
end


function Player:serialise()
    -- Record IDs of all items in inventory
    local item_ids = {}
    for _, item in ipairs(self.inventory) do
        for _ = 1, item:get_stack_size() do
            table.insert(item_ids, item:get_id())
        end
    end
    return
    {
        item_ids = item_ids,
        inventory_capacity = self.inventory_capacity,
        cur_item_idx = self.cur_item_idx,
        stamina = self.stamina,
        stamina_max = self.stamina_max,
        running_stamina = self.running_stamina,
        running_stamina_max = self.running_stamina_max,
        run = self.run,
        facing_direction = self:get_facing_direction(),
        x = self:get_x(),
        y = self:get_y()
    }
end


function Player:deserialise(saved_data)
    if not SaveHelper.verify_has_keys(saved_data, REQUIRED_SERIALISATION_KEYS) then
        return false
    end

    self.inventory_capacity = saved_data.inventory_capacity
    self.cur_item_idx = saved_data.cur_item_idx
    self.stamina = saved_data.stamina
    self.stamina_max = saved_data.stamina_max
    self.running_stamina = saved_data.running_stamina
    self.running_stamina_max = saved_data.running_stamina_max
    self.run = saved_data.run
    self:moveTo(saved_data.x, saved_data.y)
    self:set_facing_direction(saved_data.facing_direction)

    -- Inflate all the items
    for i, item_id in ipairs(saved_data.item_ids) do
        self:inventory_add(ItemFactory.new_item(item_id))
    end

    return true
end


function Player:use_item()
    local cur_item = self.inventory[self.cur_item_idx]
    if cur_item == nil or not cur_item:is_usable() then
        return false
    end

    local result = cur_item:use(self)

    if cur_item:is_stack_empty() then
        -- bye bye
        self:remove_inventory_item(self.cur_item_idx)
    end

    return result
end


function Player:update_stamina(delta)
    self.stamina -= delta

    if self.stamina < 0 then
        self.stamina = 0
    elseif self.stamina > self.stamina_max then
        self.stamina = self.stamina_max
    end

    return self.stamina > 0
end


function Player:update_running_stamina(delta)
    self.running_stamina -= delta

    if self.running_stamina < 0 then
        self.running_stamina = 0
    elseif self.running_stamina > self.running_stamina_max then
        self.running_stamina = self.running_stamina_max
    end

    return self.running_stamina > 0
end


function Player:can_run()
    return self.run
end


function Player:next_day(passed_out)
    if passed_out then
        self.stamina = math.ceil(self.stamina_max * 0.5)
    else
        self.stamina = self.stamina_max
    end
end


function Player:update()
    if FarmGame:get_state() == Global.STATES.PLAYING and not FarmGame:is_paused() then
        -- Update the currently held item if needed
        local cur_item = self:get_held_item()
        local can_move = true

        if cur_item ~= nil then
            cur_item:update(self)
            can_move = cur_item:can_player_move()
        end

        -- Update Movement
        if can_move then
            local directions = {}

            if playdate.buttonIsPressed(playdate.kButtonUp) then
                table.insert(directions, Global.DIRECTIONS.NORTH)
            end

            if playdate.buttonIsPressed(playdate.kButtonDown) then
                table.insert(directions, Global.DIRECTIONS.SOUTH)
            end

            if playdate.buttonIsPressed(playdate.kButtonLeft) then
                table.insert(directions, Global.DIRECTIONS.WEST)
            end

            if playdate.buttonIsPressed(playdate.kButtonRight) then
                table.insert(directions, Global.DIRECTIONS.EAST)
            end

            -- Regenerate stamina based on crank
            if self:can_run() then
                local delta = (math.max(0, playdate.getCrankChange()) / RUN_STAMINA_REV_RATIO) * self.stamina_max
                self:update_running_stamina(-delta)
            end

            if #directions > 0 then
                if self:can_run() and self.running_stamina > 0 then
                    self:set_speed(self.default_speed * self.running_multiplier)
                    self:update_running_stamina(1)
                else
                    self:set_speed(self.default_speed)
                end

                self:move(directions)
                -- print("[DEBUG] Player moved to (" .. self:get_x() .. ", " .. self:get_y() .. ")")
            end
        end
    end
end


function Player:get_inventory()
    return self.inventory
end


function Player:get_inventory_item(index)
    return self.inventory[index]
end


function Player:get_stamina_ratio()
    return self.stamina / self.stamina_max
end


function Player:get_running_ratio()
    return self.running_stamina / self.running_stamina_max
end


function Player:remove_inventory_item(index)
    table.remove(self.inventory, index)
end


function Player:get_held_item_idx()
    return self.cur_item_idx
end


function Player:set_held_item_idx(index)
    local cur_held_item = self:get_held_item()

    if cur_held_item ~= nil then
        cur_held_item:on_unequip(self)
    end

    self.cur_item_idx = index

    cur_held_item = self:get_held_item()

    if cur_held_item ~= nil then
        cur_held_item:on_equip(self)
    end
end


function Player:get_held_item()
    return self.inventory[self.cur_item_idx]
end


function Player:get_inventory_capacity()
    return self.inventory_capacity
end


function Player:is_inventory_full()
    return self.inventory_capacity <= #self.inventory
end


function Player:is_held_item_usable()
    local held_item = self.inventory[self.cur_item_idx]

    if held_item ~= nil then
        return self.inventory[self.cur_item_idx].is_usable()
    end

    return false
end


function Player:inventory_add(new_item)
    local item_data = Global.ITEM_DATA[new_item:get_id()]

    if item_data.obtain_dialogue ~= nil then
        FarmGame:queue_dialogue(item_data.obtain_dialogue)
    end

    -- Running shoes are special
    if new_item:get_id() == Global.ITEMS.RUNNING_SHOES then
        self.run = true
        return
    end

    -- See if we already have this item id in our inventory
    local stacked = false
    for _, item in ipairs(self.inventory) do
        if item:get_id() == new_item:get_id() and item:is_stack_space_available() then
            item:stack_add()
            stacked = true
            break
        end
    end

    if not stacked and not self:is_inventory_full() then
        table.insert(self.inventory, new_item)

        if self.cur_item_idx == #self.inventory then
            self:get_held_item():on_equip(self)
        end

        return true
    end

    return stacked
end
