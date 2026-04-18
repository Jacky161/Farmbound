import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry
local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()


local BORDER_OFFSET <const> = 5
local HELD_ITEM_SIZE <const> =
{
    WIDTH = 50,
    HEIGHT = 50
}
local HELD_ITEM_RECT <const> = geometry.rect.new(
    DISPLAY_WIDTH - HELD_ITEM_SIZE.WIDTH - BORDER_OFFSET,
    BORDER_OFFSET,
    HELD_ITEM_SIZE.WIDTH,
    HELD_ITEM_SIZE.HEIGHT)
local INFO_RECT <const> = geometry.rect.new(
    HELD_ITEM_RECT.x,
    HELD_ITEM_RECT.y + HELD_ITEM_SIZE.HEIGHT,
    HELD_ITEM_SIZE.WIDTH,
    20
)
local TEXT_INFO_RECT <const> = INFO_RECT:copy()
TEXT_INFO_RECT.y += 2

local INFO_RECT_2 <const> = geometry.rect.new(
    INFO_RECT.x,
    INFO_RECT.y + INFO_RECT.height,
    INFO_RECT.width,
    20
)
local BOTTOM_TEXT_X_SPACING <const> = 30
local BOTTOM_TEXT_Y_SPACING <const> = 10
local BOTTOM_TEXT_HEIGHT <const> = 30
local BOTTOM_TEXT_RECT <const> = geometry.rect.new(
    BOTTOM_TEXT_X_SPACING,
    DISPLAY_HEIGHT - BOTTOM_TEXT_HEIGHT - BOTTOM_TEXT_Y_SPACING,
    DISPLAY_WIDTH - BOTTOM_TEXT_X_SPACING * 2,
    BOTTOM_TEXT_HEIGHT
)
local BOTTOM_TEXT_TEXT_RECT <const> = BOTTOM_TEXT_RECT:copy()
BOTTOM_TEXT_TEXT_RECT.x += 5
BOTTOM_TEXT_TEXT_RECT.y += 7
BOTTOM_TEXT_TEXT_RECT.width -= 5
BOTTOM_TEXT_TEXT_RECT.height -= 7

local STAMINA_RECT_SIZE <const> =
{
    WIDTH = 20,
    HEIGHT = 60
}
local STAMINA_RECT <const> = geometry.rect.new(
    DISPLAY_WIDTH - BORDER_OFFSET - STAMINA_RECT_SIZE.WIDTH,
    DISPLAY_HEIGHT - BORDER_OFFSET - STAMINA_RECT_SIZE.HEIGHT,
    STAMINA_RECT_SIZE.WIDTH,
    STAMINA_RECT_SIZE.HEIGHT
)
local RUNNING_STAMINA_RECT <const> = geometry.rect.new(
    20,
    DISPLAY_HEIGHT - 4,
    DISPLAY_WIDTH - 40,
    4
)


local function fill_stroke_rect(rect)
    local prev_colour = gfx.getColor()

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(rect)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(rect)

    gfx.setColor(prev_colour)
end


class("UI").extends(gfx.sprite)
function UI:init()
    UI.super.init(self)  -- this is critical

    self:setBounds(0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT)
    -- self:setSize(DISPLAY_WIDTH, DISPLAY_HEIGHT)
    -- self:setCenter(0, 0)

    self:setIgnoresDrawOffset(true)
    self:reset()
end


function UI:reset()
    self.bottom_text = nil
end


function UI:draw_held_item_box()
    -- Held item rect and outline
    fill_stroke_rect(HELD_ITEM_RECT)

    -- Current held item sprite
    local cur_item = FarmGame:get_held_item()

    if cur_item ~= nil then
        cur_item:get_image():draw(HELD_ITEM_RECT.x + 5, HELD_ITEM_RECT.y + 5)
    end
end


function UI:draw_current_time()
    fill_stroke_rect(INFO_RECT)
    local time = FarmGame:get_time()
    gfx.drawTextInRect(string.format("%02d:%02d", time.hour, time.minute), TEXT_INFO_RECT, nil, nil, kTextAlignment.center)
end


function UI:draw_money()
    fill_stroke_rect(INFO_RECT_2)
    gfx.drawText("$" .. FarmGame:get_balance(), INFO_RECT_2.x + 2, INFO_RECT_2.y + 2)
end


function UI:draw_stamina()
    local filled_portion = STAMINA_RECT:copy()
    local stamina_height_dropped = filled_portion.height * (1 - FarmGame:get_stamina_ratio())
    filled_portion.y += stamina_height_dropped
    filled_portion.height -= stamina_height_dropped

    -- Clear area
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(STAMINA_RECT, 3)

    -- Filled portion
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(filled_portion, 3)

    -- Draw outline
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(STAMINA_RECT, 3)
end


function UI:draw_running_stamina()
    local filled_portion = RUNNING_STAMINA_RECT:copy()
    local stamina_length_dropped = filled_portion.width * (1 - FarmGame:get_running_ratio())
    filled_portion.width -= stamina_length_dropped

    -- Clear Area
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(RUNNING_STAMINA_RECT)

    -- Filled portion
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(filled_portion)

    -- Draw outline
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(RUNNING_STAMINA_RECT)
end


function UI:set_bottom_text(text)
    self.bottom_text = text
end


function UI:draw_bottom_text()
    if self.bottom_text ~= nil then
        fill_stroke_rect(BOTTOM_TEXT_RECT)
        gfx.drawTextInRect(self.bottom_text, BOTTOM_TEXT_TEXT_RECT, nil, nil, kTextAlignment.center)
    end
end


function UI:draw(x, y, width, height)
    self:draw_held_item_box()
    self:draw_current_time()
    self:draw_money()
    self:draw_stamina()

    if FarmGame:can_run() then
        self:draw_running_stamina()
    end

    self:draw_bottom_text()
end
