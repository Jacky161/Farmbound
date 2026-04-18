import "libraries/pulp-audio/pulp-audio"
import "libraries/pulp-audio/pulp-audio-extensions"
import "code/global"
import "code/visual/bobber"
import "code/ui/effects/effect_crosshair"
import "code/ui/effects/effect_auto_powerbar"
import "code/ui/effects/effect_powerbar"
import "code/items/item"
import "code/items/item_factory"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics
local CRANK_THRESHOLD <const> = 5

local FISHING_ROD_STATES <const> =
{
    IDLE = 1,
    CHARGING = 2,
    CAST = 3,
    FISHING = 4,
    FISH_ONLINE = 5,
    CATCHING = 6,
    CAUGHT = 7
}
local CASTING_BAR_DIMS <const> =
{
    WIDTH = 100,
    HEIGHT = 25
}
local CATCHING_BAR_DIMS <const> =
{
    WIDTH = 100,
    HEIGHT = 25
}
local FISH_MIN_TIME <const> = 3000
local FISH_MAX_TIME <const> = 15000
local CATCHING_DECREASE_RATE <const> = -0.02

-- The higher this is, the more that the player needs to crank to increase the catching bar.
local CATCHING_REV_RATIO <const> = 360 * 3

local CATCHING_GOOD_RANGE <const> = {0.40, 0.60}
local CATCHING_TIME <const> = 3000
local CAST_LENGTH_MAX <const> = 100
local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()


class("FishingRod").extends("Item")
function FishingRod:init()
    FishingRod.super.init(self, Global.ITEM_DATA[Global.ITEMS.FISHING_ROD])

    -- We just put (0, 0) for now because they get moved before they're shown on screen anyway
    self.bobber = Bobber(0, 0)
    self.state = FISHING_ROD_STATES.IDLE
    self.casting_powerbar = EffectAutoPowerbar(0, 0, CASTING_BAR_DIMS.WIDTH, CASTING_BAR_DIMS.HEIGHT, 1500)
    self.catching_powerbar = EffectPowerbar(0, 0, CATCHING_BAR_DIMS.WIDTH, CATCHING_BAR_DIMS.HEIGHT, 0.25)
    self.catching_powerbar:set_indicator_arrows(CATCHING_GOOD_RANGE[1], CATCHING_GOOD_RANGE[2])

    self.catching_timer = nil

    self.range_radius = 150
    self.centre =
    {
        x = 0,
        y = 0
    }

    self.user = nil
end


function FishingRod:switch_state(new_state)
    if self.state == new_state then
        return
    end

    self.state = new_state

    if new_state == FISHING_ROD_STATES.IDLE then
        -- self.crosshair:remove()
        self.casting_powerbar:remove()
        self.catching_powerbar:remove()
        self.bobber:remove()
        -- FarmGame:set_bottom_text(nil)
    elseif new_state == FISHING_ROD_STATES.CHARGING then
        self.user:update_stamina(self:get_use_penalty())

        if FarmGame:check_passout() then
            return self:switch_state(FISHING_ROD_STATES.IDLE)
        end

        self.centre =
        {
            x = FarmGame:get_player_x(),
            y = FarmGame:get_player_y()
        }

        self.state = FISHING_ROD_STATES.CHARGING
        self.casting_powerbar:moveTo(self.centre.x, self.centre.y + FarmGame:get_player_height() / 2 + 20)
        self.casting_powerbar:add()

        -- FarmGame:set_bottom_text("Crank to cast the rod!")
    elseif new_state == FISHING_ROD_STATES.CAST then
        self.casting_powerbar:pause()
        -- FarmGame:set_bottom_text("Stop cranking.")

        -- In 1 second, move to fishing state
        local cooldown = playdate.timer.new(1000, function ()
            if self.state ~= FISHING_ROD_STATES.CAST then
                return
            end

            local fill_ratio = self.casting_powerbar:get_fill_ratio()

            -- Get a point that is fill_ratio% of the way there and place a bobber
            local cast_x, cast_y = self:get_casting_coords()

            local dist_x = cast_x - self.centre.x
            local dist_y = cast_y - self.centre.y
            local bobber_x = self.centre.x + dist_x * fill_ratio
            local bobber_y = self.centre.y + dist_y * fill_ratio

            -- Check to see if theres a water tile there
            if (FarmGame:get_closest_tile(bobber_x, bobber_y, 0, 0, Global.TILE_TYPES.tile_water) ~= nil) then
                print("[DEBUG] Fishing at (" .. bobber_x .. ", " .. bobber_y .. ")")
                self.bobber:moveTo(bobber_x, bobber_y)
                self.bobber:add()

                self:switch_state(FISHING_ROD_STATES.FISHING)
            else
                print("[DEBUG] Invalid fishing location: (" .. bobber_x .. ", " .. bobber_y .. ")")
                self:switch_state(FISHING_ROD_STATES.IDLE)
            end
        end)
    elseif new_state == FISHING_ROD_STATES.FISHING then
        -- self.crosshair:remove()
        self.casting_powerbar:remove()
        -- FarmGame:set_bottom_text("Crank when a fish appears!")

        -- Wait for a certain amount of time before a fish comes
        local fish_timer = playdate.timer.new(math.random(FISH_MIN_TIME, FISH_MAX_TIME), function ()
            if self.state ~= FISHING_ROD_STATES.FISHING then
                return
            end

            self:switch_state(FISHING_ROD_STATES.FISH_ONLINE)
        end)
    elseif new_state == FISHING_ROD_STATES.FISH_ONLINE then
        -- Play a "happy" sound :)
        pulpextended.audio.playSoundOneshot("fish_good_range", 1000)
        self.user:emote("!")
        -- FarmGame:set_bottom_text("Crank now!")

        local timeout = playdate.timer.new(1000, function ()
            if self.state ~= FISHING_ROD_STATES.FISH_ONLINE then
                return
            end
            self.user:unemote()
            self:switch_state(FISHING_ROD_STATES.FISHING)
        end)
    elseif new_state == FISHING_ROD_STATES.CATCHING then
        self.user:unemote()
        self.catching_powerbar:moveTo(self.centre.x, self.centre.y + FarmGame:get_player_height() / 2 + 20)
        self.catching_powerbar:reset()
        self.catching_powerbar:add()
        -- FarmGame:set_bottom_text("Crank to keep the bar half filled!")
    elseif new_state == FISHING_ROD_STATES.CAUGHT then
        self.user:inventory_add(ItemFactory.new_item(Global.ITEMS.FISH))
        FarmGame:update_stat(Global.STATS.NUM_FISH_CAUGHT.stat_id, 1)
        self:switch_state(FISHING_ROD_STATES.IDLE)
        -- FarmGame:set_bottom_text(nil)
    end

    -- Clear any remaining crank change
    playdate.getCrankChange()
end


function FishingRod:get_casting_coords()
    local player_direction = self.user:get_facing_direction()
    local max_x = self.user:get_x()
    local max_y = self.user:get_y()

    if player_direction == Global.DIRECTIONS.NORTH then
        max_y -= CAST_LENGTH_MAX
    elseif player_direction == Global.DIRECTIONS.SOUTH then
        max_y += CAST_LENGTH_MAX
    elseif player_direction == Global.DIRECTIONS.EAST then
        max_x += CAST_LENGTH_MAX
    elseif player_direction == Global.DIRECTIONS.WEST then
        max_x -= CAST_LENGTH_MAX
    end

    return max_x, max_y
end


function FishingRod:use(user)
    if self.state == FISHING_ROD_STATES.IDLE and playdate.buttonJustReleased(playdate.kButtonA) and not playdate.isCrankDocked() then
        self:switch_state(FISHING_ROD_STATES.CHARGING)
    end
end


function FishingRod:is_usable()
    return true
end


function FishingRod:get_use_penalty()
    return 5
end


function FishingRod:update(user)
    if playdate.isCrankDocked() then
        self:switch_state(FISHING_ROD_STATES.IDLE)
        FarmGame:draw_crank_indicator()
    elseif self.state == FISHING_ROD_STATES.CHARGING then
        -- Wait for a crank change of at least threshold degrees
        local change = playdate.getCrankChange()

        if change >= CRANK_THRESHOLD then
            self:switch_state(FISHING_ROD_STATES.CAST)
        end
    elseif self.state == FISHING_ROD_STATES.FISHING then
        -- If they crank the threshold then we cancel out of fishing
        local change = playdate.getCrankChange()

        if change >= CRANK_THRESHOLD then
            self:switch_state(FISHING_ROD_STATES.IDLE)
        end
    elseif self.state == FISHING_ROD_STATES.FISH_ONLINE then
        -- If they crank the threshold then we start catching
        local change = playdate.getCrankChange()

        if change >= CRANK_THRESHOLD then
            self:switch_state(FISHING_ROD_STATES.CATCHING)
        end
    elseif self.state == FISHING_ROD_STATES.CATCHING then
        -- Decrease the charge and if they crank, increase the ratio
        local revolution_ratio = math.max(0, playdate.getCrankChange()) / CATCHING_REV_RATIO
        self.catching_powerbar:set_fill_ratio_by(CATCHING_DECREASE_RATE + revolution_ratio)

        local cur_fill_ratio = self.catching_powerbar:get_fill_ratio()

        if cur_fill_ratio >= CATCHING_GOOD_RANGE[1] and cur_fill_ratio <= CATCHING_GOOD_RANGE[2] then
            -- Play a "happy" sound :)
            pulpextended.audio.playSoundOneshot("fish_good_range", 500)

            -- Start a timer for when they caught it
            if self.catching_timer == nil then
                self.catching_timer = playdate.timer.new(CATCHING_TIME, function ()
                    if self.state ~= FISHING_ROD_STATES.CATCHING then
                        return
                    end

                    self:switch_state(FISHING_ROD_STATES.CAUGHT)
                end)
            end
        else
            if self.catching_timer ~= nil then
                self.catching_timer:remove()
                self.catching_timer = nil
            end

            if cur_fill_ratio <= 0 or cur_fill_ratio >= 1 then
                self:switch_state(FISHING_ROD_STATES.IDLE)
            end
        end
    end
end


function FishingRod:on_unequip(user)
    self:switch_state(FISHING_ROD_STATES.IDLE)
    self.user = nil
end


function FishingRod:on_equip(user)
    self.user = user
end


function FishingRod:can_player_move()
    return self.state == FISHING_ROD_STATES.IDLE
end
