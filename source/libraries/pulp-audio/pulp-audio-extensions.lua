import "libraries/pulp-audio/pulp-audio"
import "CoreLibs/timer"


local playSoundOneshot

local sounds_playing = {}


function playSoundOneshot(value, repeat_duration)
    if sounds_playing[value] ~= nil then
        return
    end
    sounds_playing[value] = true

    pulp.audio.playSound(value)

    playdate.timer.new(repeat_duration, function ()
        sounds_playing[value] = nil
    end)
end


pulpextended =
{
    audio =
    {
        playSoundOneshot = playSoundOneshot
    }
}
