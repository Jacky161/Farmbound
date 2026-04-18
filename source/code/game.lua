import "code/actors/npc"
import "code/actors/player"
import "code/actors/shopkeeper"

import "code/global"

import "code/helpers/drawhelper"
import "code/helpers/savehelper"

import "code/items/item_factory"

import "code/managers/objectivemgr"
import "code/managers/statsmgr"

import "code/ui/effects/effect_spray"
import "code/ui/effects/effect_circle_fade"

import "code/ui/menus/game_over_menu"
import "code/ui/menus/inventory_menu"
import "code/ui/menus/load_menu"
import "code/ui/menus/load_fail_menu"
import "code/ui/menus/main_menu"
import "code/ui/menus/ship_menu"
import "code/ui/menus/shop_menu"

import "code/ui/ui"

import "code/world"

import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry
local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()
local BORDER_SCROLL_MARGIN <const> = 50
local REQUIRED_SERIALISATION_KEYS <const> =
{
    "world",
    "actors",
    "player",
    "time",
    "money",
    "pending_money",
    "statsmgr",
    "objmgr",
    "autosave",
    "game_build_no",
    "serialisation_time"
}


class("Game").extends()


function Game:init()
    self.block_a = false
    self.paused = false
    self.npcs = nil
    self.fake_npc = nil
    self.was_emoting = false
    self.autosave = true
    self.queued_dialogue = {}

    self:reset()
    self:init_npcs()

    -- Screen wide drawing helper for drawing closest tile
    local x, y, width, height = self.world:getBounds()
    self.draw_helper = DrawHelper(width, height)
    self.draw_helper:add()
    self.closest_tile_key = DrawHelper.gen_key()

    -- self.camera =
    -- {
    --     x = 0,
    --     y = 0
    -- }
end


function Game:reset()
    if self.world == nil then
        -- Build the world
        self.world = World()
    else
        self.world:reset()
    end

    if self.ui == nil then
        -- Initialise UI
        self.ui = UI()
        self.ui:add()
    else
        self.ui:reset()
    end

    self.should_draw_crank = false

    -- Spawn player
    if self.player == nil then
        self.player = Player(self.world:get_poi(Global.POIS.PLAYER_SPAWN))
    else
        self.player:reset()
        self.player:moveTo(self.world:get_poi(Global.POIS.PLAYER_SPAWN))
    end

    self.menu = nil

    self.time = nil
    self.time_timer = nil
    self:reset_time()

    self.money = 100
    self.pending_money = 0

    self.statsmgr = StatsMgr(Global.STATS)
    self.objmgr = ObjectiveMgr(self.statsmgr, function ()
        self:new_obj()
    end)
    self.game_over = false

    if self.npcs ~= nil then
        for _, actor in ipairs(self.npcs) do
            actor:reset()
        end
    end

    -- Check for existing saved data
    local saved_data = playdate.datastore.read()
    if saved_data and saved_data.serialisation_time ~= nil and saved_data.game_build_no == playdate.metadata.buildNumber then
        self:switch_state(Global.STATES.MENU_LOAD, saved_data)
    else
        self:switch_state(Global.STATES.MAIN_MENU)
    end
end


function Game:serialise()
    local actor_data = {}

    for i, actor in ipairs(self.npcs) do
        actor_data[i] = actor:serialise()
    end

    return
    {
        world = self.world:serialise(),
        actors = actor_data,
        player = self.player:serialise(),
        time = self.time,
        money = self.money,
        pending_money = self.pending_money,
        statsmgr = self.statsmgr:serialise(),
        objmgr = self.objmgr:serialise(),
        autosave = self.autosave,
        game_build_no = playdate.metadata.buildNumber,
        serialisation_time = playdate.getTime()
    }
end


function Game:deserialise(saved_data)
    print("[DEBUG] Trying to deserialise saved data.")
    if not SaveHelper.verify_has_keys(saved_data, REQUIRED_SERIALISATION_KEYS) then
        print("[ERROR] Required keys not found in saved game data.")
        return false
    end

    if not self.world:deserialise(saved_data.world) then
        print("[ERROR] World failed to deserialise!")
        return false
    end

    for i, actor_data in pairs(saved_data.actors) do
        if not self.npcs[i]:deserialise(actor_data) then
            return false
        end
    end

    if not self.player:deserialise(saved_data.player) then
        print("[ERROR] Player failed to deserialise!")
        return false
    end

    self.time = saved_data.time
    self.money = saved_data.money
    self.pending_money = saved_data.pending_money

    if not self.statsmgr:deserialise(saved_data.statsmgr) then
        print("[ERROR] statsmgr failed to deserialise!")
        return false
    end

    if not self.objmgr:deserialise(saved_data.objmgr) then
        print("[ERROR] objmgr failed to deserialise!")
        return false
    end

    self.autosave = saved_data.autosave
    -- Reset any queued dialogue
    self.queued_dialogue = {}

    print("[DEBUG] Game successfully deserialised!")
    return true
end


function Game:setup_menu()
    local menu = playdate.getSystemMenu()
    menu:removeAllMenuItems()

    if self.state ~= Global.STATES.MAIN_MENU and self.state ~= Global.STATES.GAME_OVER and self.state ~= Global.STATES.MENU_LOAD and self.state ~= Global.STATES.MENU_LOAD_FAIL then
        menu:addCheckmarkMenuItem("Autosave", self.autosave, function (choice)
            self.autosave = choice
        end)
        menu:addMenuItem("Save", function ()
            SaveGame()
        end)
    end
end


function Game:show_dialogue(dialogue)
    self.fake_npc:set_dialogue(dialogue)
    self.fake_npc:interact(self)
end


function Game:queue_dialogue(dialogue)
    table.insert(self.queued_dialogue, dialogue)
end


function Game:new_obj()
    self:queue_dialogue({"A new objective has been added! Press B to view it on the objective screen."})
end


function Game:init_npcs()
    self.npcs = {}

    for i, shopkeeper_data in ipairs(Global.SHOPKEEPER_DATA) do
        table.insert(self.npcs, Shopkeeper(shopkeeper_data, i, self.world:get_poi(shopkeeper_data.name)))
    end

    for _, npc_data in ipairs(Global.NPC_DATA) do
        local npc = NPC(npc_data, self.world:get_poi(npc_data.name))
        table.insert(self.npcs, npc)

        if npc_data.name == "fakenpc" then
            self.fake_npc = npc
        end
    end

    if self.fake_npc == nil then
        error("[ERROR] FakeNPC for dialogue not found.")
    end
end


function Game:switch_state(new_state, transition_data)
    self.state = new_state
    self.menu = nil

    if new_state == Global.STATES.MAIN_MENU then
        self:jumpstart_menu_main()
    elseif new_state == Global.STATES.MENU_LOAD then
        self:jumpstart_menu_load(transition_data)
    elseif new_state == Global.STATES.MENU_LOAD_FAIL then
        self:jumpstart_menu_load_fail()
    elseif new_state == Global.STATES.MENU_INVENTORY then
        self:jumpstart_menu_inventory()
    elseif new_state == Global.STATES.MENU_SHIP then
        self:jumpstart_menu_ship()
    elseif new_state == Global.STATES.MENU_SHOP then
        self:jumpstart_menu_shop(transition_data)
    elseif new_state == Global.STATES.GAME_OVER then
        self:jumpstart_menu_gameover()
    elseif new_state == Global.STATES.TRANSITION then
        if transition_data == nil then
            transition_data =
            {
                x = DISPLAY_WIDTH / 2,
                y = DISPLAY_HEIGHT / 2,
                transition_duration = 2000,
                pause_period = 500
            }
        end
        self:jumpstart_transition(transition_data)
    end

    if new_state == Global.STATES.PLAYING then
        self.time_timer:start()
    else
        self.time_timer:pause()
    end

    -- Add or remove saving as needed
    self:setup_menu()
end


-- function Game:update_camera_position()
--     -- Get player position
--     local rel_player_pos = {x = self.player:get_x() + self.camera.x, y = self.player:get_y() + self.camera.y}

--     -- If the player is near the edge of the screen, move the camera accordingly
--     while rel_player_pos.x <= BORDER_SCROLL_MARGIN do
--         -- Too close to the left edge
--         self.camera.x += self.player:get_speed()
--         rel_player_pos = {x = self.player:get_x() + self.camera.x, y = self.player:get_y() + self.camera.y}
--     end
--     while DISPLAY_WIDTH - rel_player_pos.x <= BORDER_SCROLL_MARGIN do
--         -- Too close to right edge
--         self.camera.x -= self.player:get_speed()
--         rel_player_pos = {x = self.player:get_x() + self.camera.x, y = self.player:get_y() + self.camera.y}
--     end

--     while rel_player_pos.y <= BORDER_SCROLL_MARGIN do
--         -- Too close to the top edge
--         self.camera.y += self.player:get_speed()
--         rel_player_pos = {x = self.player:get_x() + self.camera.x, y = self.player:get_y() + self.camera.y}
--     end
--     while DISPLAY_HEIGHT - rel_player_pos.y <= BORDER_SCROLL_MARGIN do
--         -- Too close to the bottom edge
--         self.camera.y -= self.player:get_speed()
--         rel_player_pos = {x = self.player:get_x() + self.camera.x, y = self.player:get_y() + self.camera.y}
--     end
-- end


function Game:draw_playing()
    gfx.clear()

    -- Update camera position
    gfx.setDrawOffset(-self.player.x + DISPLAY_WIDTH / 2, -self.player.y + DISPLAY_HEIGHT / 2)

    -- Render game world and sprites
    gfx.sprite.update()

    -- If usable item, draw a box in front of the player to indicate their hit location
    local draw_closest_tile = nil

    if self.player:is_held_item_usable() then
        local closest_tile = self:get_closest_farmtile_to_player(1)

        if closest_tile ~= nil then
            draw_closest_tile = function ()
                gfx.drawRect(closest_tile:get_x(), closest_tile:get_y(), 32, 32)
            end
        end
    end

    self.draw_helper:set_draw_func(self.closest_tile_key, draw_closest_tile)

    -- Show exclamation mark above player's head if they can interact
    if not self.paused and self:try_a() then
        self.was_emoting = true
        self.player:emote("!")
    elseif self.was_emoting then
        self.was_emoting = false
        self.player:unemote()
    end

    -- DEBUG
    -- local cur_held = self.player:get_held_item()
    -- if cur_held ~= nil and cur_held.className == "WaterGun" then
    --     if cur_held.effect_spray ~= nil then
    --         gfx.drawRect(cur_held.effect_spray:getBoundsRect())
    --     end
    -- end
end


function Game:update_playing()
    -- self:update_camera_position()

    if self.paused then
        return
    end

    if #self.queued_dialogue > 0 then
        self:show_dialogue(table.remove(self.queued_dialogue, 1))
    end

    if self.game_over then
        self:switch_state(Global.STATES.GAME_OVER)
        return
    end

    -- Did the player pass out?
    if self:check_passout() then
        self:switch_state(Global.STATES.TRANSITION)
        return
    end

    if playdate.buttonJustReleased(playdate.kButtonA) and not self.block_a then
        self:handle_a()
    end
    if playdate.buttonJustReleased(playdate.kButtonB) then
        self:switch_state(Global.STATES.MENU_INVENTORY)
    end

    self.block_a = false
end


function Game:try_a()
    if self.player:colliding_with(Global.COLLISION_TAGS.HOUSE) ~= nil or
       self.player:colliding_with(Global.COLLISION_TAGS.SHIPPING_BOX) ~= nil or
       self.player:colliding_with(Global.COLLISION_TAGS.NPC)
    then
        return true
    end

    local loading_zones = self.world:get_loading_zones()
    for collision_tag, loc in pairs(loading_zones) do
        if self.player:colliding_with(collision_tag) then
            return true
        end
    end

    return false
end


function Game:handle_a()
    -- First, try to see if we can interact with the house
    if self.player:colliding_with(Global.COLLISION_TAGS.HOUSE) ~= nil then
        self:next_day()
        return true
    -- Shipping box?
    elseif self.player:colliding_with(Global.COLLISION_TAGS.SHIPPING_BOX) ~= nil then
        self:switch_state(Global.STATES.MENU_SHIP)
        return true
    else
        local loading_zones = self.world:get_loading_zones()
        for collision_tag, loc in pairs(loading_zones) do
            if self.player:colliding_with(collision_tag) then
                if loc.active_hour_start ~= nil and loc.active_hour_end ~= nil then
                    -- If current hour is not in between those then no
                    if self.time.hour < loc.active_hour_start or self.time.hour >= loc.active_hour_end then
                        self:queue_dialogue({string.format("It's locked. The sign says open from %02d:00 - %02d:00.", loc.active_hour_start, loc.active_hour_end)})
                        return false
                    end
                end

                print("[DEBUG] Warping to lz tag #" .. collision_tag)
                self.player:moveTo(loc.x, loc.y)
                return true
            end
        end
    end

    local npc_colliding = self.player:colliding_with(Global.COLLISION_TAGS.NPC)
    if npc_colliding ~= nil then
        npc_colliding:interact(self)
    elseif not self:try_harvest() then
        return self.player:use_item()
    end

    return true
end


function Game:check_passout()
    return self.player:get_stamina_ratio() <= 0 or self.time.hour == 24
end


function Game:try_harvest()
    if self.player:is_inventory_full() then
        return false
    end

    -- Check if we're near a farmtile that is ready to harvest
    local farmtile = self:get_closest_farmtile_to_player(1)

    if farmtile == nil then
        return false
    end

    -- Is it ready to harvest???
    local crop_id = farmtile:harvest()

    if crop_id == nil then
        return false  -- not ready to harvest
    end

    -- Instantiate an instance of the crop and add it to the player's inventory
    self.player:inventory_add(ItemFactory.new_item(Global.CROP_DATA[crop_id].crop_item_id))
    self:update_stat(Global.CROP_DATA[crop_id].harvest_stat_id, 1)
    self:update_stat(Global.STATS.NUM_HARVESTS.stat_id, 1)
    return true
end


function Game:jumpstart_menu()
    -- We draw the last frame but blurred as our background image
    local inventory_bg = gfx.getDisplayImage():blurredImage(2, 2, gfx.image.kDitherTypeScreen)

    -- No offset in the menu state
    gfx.setDrawOffset(0, 0)

    return inventory_bg
end


function Game:jumpstart_menu_main()
    self:jumpstart_menu()

    -- this is so bad
    for _, item in ipairs(Global.PLAYER_STARTING_ITEMS) do
        self.player:inventory_add(ItemFactory.new_item(item))
    end

    self.menu = MainMenu(function (_)
        self:switch_state(Global.STATES.PLAYING)
    end)
end


function Game:jumpstart_menu_load(saved_data)
    self:jumpstart_menu()

    self.menu = LoadMenu(saved_data.serialisation_time, function (choice)
        if choice == true then
            print("[DEBUG] Trying to load save game!")
            if not self:deserialise(saved_data) then
                self:switch_state(Global.STATES.MENU_LOAD_FAIL)
            else
                self:switch_state(Global.STATES.PLAYING)
            end
        else
            print("[DEBUG] Not loading save game.")
            self:switch_state(Global.STATES.MAIN_MENU)
        end
    end)
end


function Game:jumpstart_menu_load_fail()
    self:jumpstart_menu()

    self.menu = LoadFailMenu()
end


function Game:jumpstart_menu_inventory()
    local bg = self:jumpstart_menu()

    -- Select the currently held item
    local inventory_current_selection = self.player:get_held_item_idx()

    self.menu = InventoryMenu(bg, self.player:get_inventory(), function (selection)
        if selection ~= nil then
            print("[DEBUG] New selected item: " .. selection)
            self.player:set_held_item_idx(selection)
        end

        self:switch_state(Global.STATES.PLAYING)
    end, inventory_current_selection, self.player:get_inventory_capacity())
end


function Game:jumpstart_menu_ship()
    local bg = self:jumpstart_menu()

    self.menu = ShipMenu(bg, self.player:get_inventory(), function (selection)
        if selection ~= nil then
            -- SELL THE STUFF
            local item = self.player:get_inventory_item(selection)

            -- If not sellable, do nothing
            local sell_price = item:get_sell_price()
            if sell_price == nil then
                return
            end

            -- Remove a stack
            local remaining = item:stack_remove()

            if remaining <= 0 then
                self.player:remove_inventory_item(selection)
            end

            -- Add to pending money balance
            self.pending_money += sell_price

            -- Update number shipped
            self:update_stat(item:get_ship_stat_id(), 1)
            self:update_stat(Global.STATS.NUM_SHIPPED.stat_id, 1)
        end

        self:switch_state(Global.STATES.PLAYING)
    end)
end


function Game:jumpstart_menu_shop(shopkeeper)
    local bg = self:jumpstart_menu()
    local selling_inventory = shopkeeper:get_selling_inventory()

    self.menu = ShopMenu(bg, shopkeeper:get_name(), selling_inventory, function (selection)
        local should_exit = true
        if selection ~= nil then
            local item = selling_inventory[selection]
            local item_data = Global.ITEM_DATA[item.id]

            if not self.player:is_inventory_full() and item_data.purchase_price <= self:get_balance() then
                -- Buy buy buy
                self.money -= item_data.purchase_price
                self.player:inventory_add(ItemFactory.new_item(item.id))

                -- Decrease quantity if needed
                if item.quantity ~= nil then
                    item.quantity -= 1

                    if item.quantity <= 0 then
                        table.remove(selling_inventory, selection)
                    end
                end
            else
                should_exit = false
            end
        end

        if should_exit then
            self:switch_state(Global.STATES.PLAYING)
        end
    end)
end


function Game:jumpstart_menu_gameover()
    local bg = self:jumpstart_menu()

    self.menu = GameOverMenu(bg, function ()
        playdate.datastore.delete()
        self:reset()
    end)
end


function Game:jumpstart_transition(transition_info)
    local transition = EffectCircleFade(transition_info.x, transition_info.y, transition_info.transition_duration, transition_info.pause_period, function ()
        if self.state == Global.STATES.TRANSITION then
            self:switch_state(Global.STATES.PLAYING)
        end
    end, function ()
        self:tick_next_day()
    end)
    transition:add()
end


function Game:draw_menu()
    self.menu:draw()
end


function Game:update_menu()
    self.menu:update()
end


function Game:draw_transition()
    gfx.clear()
end


function Game:update_transition()
    gfx.sprite.update()
end


function Game:update()
    if self.state == Global.STATES.PLAYING then
        self:draw_playing()
        self:update_playing()
    elseif Global.STATE_IS_MENU[self.state] then
        self:draw_menu()
        self:update_menu()
    elseif self.state == Global.STATES.TRANSITION then
        self:draw_transition()
        self:update_transition()
    end

    if self.should_draw_crank then
        playdate.ui.crankIndicator:draw()
        self.should_draw_crank = false
    end
end


function Game:get_closest_tile_to_player(offset, type)
    local facing_direction = self.player:get_facing_direction()
    local x_offset = 0
    local y_offset = 0

    if facing_direction == Global.DIRECTIONS.NORTH then
        y_offset = -offset
    elseif facing_direction == Global.DIRECTIONS.EAST then
        x_offset = offset
    elseif facing_direction == Global.DIRECTIONS.SOUTH then
        y_offset = offset
    elseif facing_direction == Global.DIRECTIONS.WEST then
        x_offset = -offset
    end

    return self:get_closest_tile(self.player:get_x(), self.player:get_y(), x_offset, y_offset, type)
end


function Game:get_closest_farmtile_to_player(offset)
    return self:get_closest_tile_to_player(offset, Global.TILE_TYPES.tile_farm)
end


function Game:get_closest_tile(x, y, x_offset, y_offset, type)
    if x_offset == nil then
        x_offset = 0
    end

    if y_offset == nil then
        y_offset = 0
    end

    return self.world:get_closest_tile(x, y, x_offset, y_offset, type)
end


function Game:get_held_item()
    return self.player:get_held_item()
end


function Game:get_balance()
    return self.money
end


function Game:get_state()
    return self.state
end


function Game:get_player_x()
    return self.player:get_x()
end


function Game:get_player_y()
    return self.player:get_y()
end


function Game:get_player_width()
    return self.player:get_width()
end


function Game:get_player_height()
    return self.player:get_height()
end


function Game:get_player_facing_direction()
    return self.player:get_facing_direction()
end


function Game:get_stamina_ratio()
    return self.player:get_stamina_ratio()
end


function Game:get_running_ratio()
    return self.player:get_running_ratio()
end


function Game:can_run()
    return self.player:can_run()
end


function Game:get_time()
    return self.time
end


function Game:increment_time()
    if self.time.minute >= 50 then
        self.time.minute = 0
        self.time.hour += 1
    else
        self.time.minute += 10
    end
end


function Game:reset_time()
    self.time =
    {
        hour = 6,
        minute = 0
    }

    if self.time_timer ~= nil then
        self.time_timer:reset()
    else
        self.time_timer = playdate.timer.new(3000, function ()
            self:increment_time()
        end)
        self.time_timer.repeats = true
    end
end


function Game:next_day()
    -- Fade out the screen
    self:switch_state(Global.STATES.TRANSITION)
end


function Game:tick_next_day()
    local passed_out = self:check_passout()

    -- Update all tiles
    local tilemgr = self.world:get_tilemgr()
    tilemgr:tick_tiles()


    if passed_out then
        self.pending_money -= math.floor(self.money * 0.1)
    end

    self.player:next_day(passed_out)

    self:update_money(self.pending_money)
    self.pending_money = 0

    self:update_stat(Global.STATS.CURRENT_DAY.stat_id, 1)

    -- Reset time
    self:reset_time()

    -- objmgr returns false if the objective was failed
    self.game_over = not self.objmgr:next_day()
end


function Game:draw_crank_indicator()
    self.should_draw_crank = true
end


function Game:update_money(delta)
    self.money += delta

    if self.money <= 0 then
        self.money = 0
    end

    if delta > 0 then
        self:update_stat(Global.STATS.TOTAL_MONEY_EARNED.stat_id, delta)
    end
end


function Game:update_stat(stat_id, delta)
    return self.statsmgr:update_stat(stat_id, delta)
end


function Game:get_stat(stat_id)
    return self.statsmgr:get_stat(stat_id)
end


function Game:get_stats_mgr()
    return self.statsmgr
end


function Game:get_obj_mgr()
    return self.objmgr
end


function Game:is_paused()
    return self.paused
end


function Game:set_paused(paused)
    self.paused = paused
    self.block_a = not paused

    if self.paused then
        self.time_timer:pause()
    else
        self.time_timer:start()
    end
end


function Game:set_bottom_text(text)
    return self.ui:set_bottom_text(text)
end


function Game:is_autosave()
    return self.autosave
end
