import "libraries/pulp-audio/pulp-audio"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry
local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()

local TEXTBOX_SCREEN_LOC <const> =
{
    x = 20,
    y = DISPLAY_HEIGHT / 2 + 30
}
local TEXTBOX_WIDTH <const> = DISPLAY_WIDTH - 20 * 2
local TEXTBOX_HEIGHT <const> = DISPLAY_HEIGHT / 2 - 20 * 2
local ACTUAL_TEXT_RECT <const> = geometry.rect.new(10, 10, TEXTBOX_WIDTH - 20, TEXTBOX_HEIGHT - 20)


local function randf(lower, greater)
    return lower + math.random()  * (greater - lower);
end


class("Textbox").extends(gfx.sprite)
function Textbox:init(texts, callback_done)
    Textbox.super.init(self)  -- this is critical
    self:setBounds(TEXTBOX_SCREEN_LOC.x, TEXTBOX_SCREEN_LOC.y, TEXTBOX_WIDTH, TEXTBOX_HEIGHT)
    self:setIgnoresDrawOffset(true)

    self.callback_done = callback_done
    self.texts = texts
    self.cur_text = 1
    self.cur_text_pos = 1

    self.text_timer = nil
    self.synth = playdate.sound.synth.new(playdate.sound.kWaveSine)
end


function Textbox:draw(x, y, width, height)
    -- Outer fill
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(0, 0, TEXTBOX_WIDTH, TEXTBOX_HEIGHT, 5)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(0, 0, TEXTBOX_WIDTH, TEXTBOX_HEIGHT, 5)

    -- Inner fill
    gfx.fillRect(5, 5, TEXTBOX_WIDTH - 10, TEXTBOX_HEIGHT - 10)

    -- Draw some text
    gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
    gfx.drawTextInRect(string.sub(self.texts[self.cur_text], 1, self.cur_text_pos), ACTUAL_TEXT_RECT)

    gfx.setImageDrawMode(playdate.graphics.kDrawModeCopy)

    -- Draw next text arrow if there is more
    if self:next_page_ready() then
        local triangle_base_x = self.width - 30
        local triangle_base_y = self.height - 8
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(triangle_base_x, triangle_base_y, 10, 8)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillTriangle(triangle_base_x, triangle_base_y, triangle_base_x + 10, triangle_base_y, triangle_base_x + 5, triangle_base_y + 7)
    end
end


function Textbox:setup_text_timer()
    -- Every interval, append a new character to the text
    self.text_timer = playdate.timer.new(5, Textbox.add_char, self)
    self.text_timer.repeats = true
end


function Textbox:stop_text_timer()
    if self.text_timer ~= nil then
        self.text_timer:remove()
        self.text_timer = nil
    end
end


function Textbox:add()
    Textbox.super.add(self)
    self:setup_text_timer()
end


function Textbox:remove()
    Textbox.super.remove(self)
    self:stop_text_timer()
    self.callback_done(self)
end


function Textbox:update()
    if self:next_page_ready() and playdate.buttonJustReleased(playdate.kButtonA) then
        self.cur_text += 1
        self.cur_text_pos = 1
        self:setup_text_timer()
    elseif self:exit_ready() and playdate.buttonJustReleased(playdate.kButtonA) then
        self:remove()
    end
end


function Textbox:add_char()
    if playdate.buttonIsPressed(playdate.kButtonB) then
        self.cur_text_pos += 1
    end
    self.cur_text_pos += 1

    if self.cur_text_pos >= #self.texts[self.cur_text] then
        self.cur_text_pos = #self.texts[self.cur_text]
        self:stop_text_timer()

        -- if self:next_page_ready() then
        --     pulp.audio.playSound("dialogue_next")
        -- end
    else
        -- Play a new sound based on the added character
        local freq = 783.99 + randf(-0.1, 0.1)
        self.synth:playNote(freq, 0.3, 0.01)
    end
end


function Textbox:next_page_ready()
    return self.cur_text_pos >= #self.texts[self.cur_text] and self.cur_text < #self.texts
end


function Textbox:exit_ready()
    return self.cur_text_pos >= #self.texts[self.cur_text] and self.cur_text >= #self.texts
end
