--[[
MIT License

Copyright (c) 2024 Matthew Miner
Copyright (c) 2026 Jacky161

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Original Source: https://github.com/mminer/playdate-circle-transition
]]

import "CoreLibs/easing"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry

local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()


local overlay = gfx.image.new(DISPLAY_WIDTH, DISPLAY_HEIGHT, gfx.kColorBlack)
local mask = gfx.image.new(DISPLAY_WIDTH, DISPLAY_HEIGHT)


local function get_distance_to_farthest_corner(point)
    return math.max
    (
        point:distanceToPoint(geometry.point.new(0, 0)),
        point:distanceToPoint(geometry.point.new(DISPLAY_WIDTH, 0)),
        point:distanceToPoint(geometry.point.new(0, DISPLAY_HEIGHT)),
        point:distanceToPoint(geometry.point.new(DISPLAY_WIDTH, DISPLAY_HEIGHT))
    )
end


-- This implements a fade out effect in the shape of a circle. The circle shrinks to consume the
-- screen in black centered at the (x, y) given. This is known as an iris shot.
class("EffectCircleFade").extends(gfx.sprite)
function EffectCircleFade:init(x, y, transition_duration, pause_period, callback_done, callback_pause)
    EffectCircleFade.super.init(self)
    self.point = geometry.point.new(x, y)
    self.transition_duration = transition_duration
    self.pause_period = pause_period
    self.fade_timer = nil
    self.pause_timer = nil
    self.fading_in = false
    self.callback_done = callback_done
    self.callback_pause = callback_pause

    self:setBounds(0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT)
    self:setIgnoresDrawOffset(true)

    print("[DEBUG] EffectCircleFade initialized at (" .. self.x .. ", " .. self.y .. ")")
end


function EffectCircleFade:draw(x, y, width, height)
    gfx.pushContext(mask)
        gfx.clear(gfx.kColorWhite)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(self.point, self.fade_timer.value)
    gfx.popContext()

    overlay:setMaskImage(mask)
    overlay:draw(0, 0)

    if self.fade_timer.timeLeft <= 0 and self.pause_period ~= nil and not self.fading_in then
        -- Wait until the pause period is over, then fade back in
        self.pause_timer = playdate.timer.new(self.pause_period, function ()
            self:fade_in()
        end)
        self.callback_pause()
        self.fading_in = true
    elseif (self.pause_timer == nil or self.pause_timer.timeLeft <= 0) and self.fade_timer.timeLeft <= 0 and self.fading_in then
        -- We're done folks
        self:remove()
    end
end


function EffectCircleFade:fade_in()
    self.fade_timer = playdate.timer.new(self.transition_duration, 0, self.max_radius, playdate.easingFunctions.inOutQuad)
    self.fading_in = true
end


function EffectCircleFade:add()
    self.max_radius = get_distance_to_farthest_corner(self.point)
    self.fade_timer = playdate.timer.new(self.transition_duration, -self.max_radius, 0, playdate.easingFunctions.inOutQuad)

    EffectCircleFade.super.add(self)
end


function EffectCircleFade:remove()
    self.fade_timer:remove()
    self.fade_timer = nil
    EffectCircleFade.super.remove(self)

    if self.callback_done ~= nil then
        self.callback_done()
    end

    print("[DEBUG] EffectCircleFade finished at (" .. self.x .. ", " .. self.y .. ")")
end
