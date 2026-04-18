import "code/ui/effects/effect_powerbar"
import "CoreLibs/easing"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry


class("EffectAutoPowerbar").extends(EffectPowerbar)
function EffectAutoPowerbar:init(x, y, width, height, fill_time)
    EffectAutoPowerbar.super.init(self, x, y, width, height, 0)

    self.fill_time = fill_time
    self.fill_timer = nil
    self.fill_max = nil


    print("[DEBUG] EffectAutoPowerbar initialized at (" .. self.x .. ", " .. self.y .. ")")
end


function EffectAutoPowerbar:setup_timer()
    self.fill_timer = playdate.timer.new(self.fill_time, 0, 100, playdate.easingFunctions.inSine)

    self.fill_timer.repeats = true
    self.fill_timer.reverses = true
    self.fill_timer.updateCallback = function (timer)
        self:set_fill_ratio(timer.value / 100)
    end
end


function EffectAutoPowerbar:pause()
    self.fill_timer:pause()
end


function EffectAutoPowerbar:add()
    self:setup_timer()
    EffectAutoPowerbar.super.add(self)
end


function EffectAutoPowerbar:remove()
    EffectAutoPowerbar.super.remove(self)

    if self.fill_timer ~= nil then
        self.fill_timer:remove()
        self.fill_timer = nil
    end
end
