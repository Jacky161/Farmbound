import "libraries/pulp-audio/pulp-audio"
import "code/global"
import "code/game"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

FarmGame = Game()
DebugDrawingPoints = {

}

local function first_start_init()
    pulp.audio.init("sound/pulp/pulp-songs.json", "sound/pulp/pulp-sounds.json")
end


first_start_init()


function playdate.update()
    playdate.timer.updateTimers()
    pulp.audio.update()
    FarmGame:update()
end


function SaveGame()
    local game_state = FarmGame:get_state()
    if game_state ~= nil and game_state ~= Global.STATES.MAIN_MENU and game_state ~= Global.STATES.GAME_OVER and game_state ~= Global.STATES.MENU_LOAD and game_state ~= Global.STATES.MENU_LOAD_FAIL then
        print("[DEBUG] Saving the game...")
        playdate.datastore.write(FarmGame:serialise(), nil, true)
    end
end


function playdate.gameWillTerminate()
    if FarmGame:is_autosave() then
        return SaveGame()
    end

end


function playdate.deviceWillSleep()
    if FarmGame:is_autosave() then
        return SaveGame()
    end
end
