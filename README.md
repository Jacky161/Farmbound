# Farmbound

Farmbound is a farming simulation game developed for the Playdate console. Inspired by Stardew Valley and the Harvest Moon / Story of Seasons franchise.

## Game Info

The game features farming and fishing as the key mechanics. An objective system is present that gives the player different tasks to complete. Failing to complete these on time will result in a game over! View the [game manual](docs/MANUAL.md) for more details.

## Images

![Watering Crops using the Water Gun Item](assets/water_gun.gif)
![Chilling in the Town](assets/cozy_town.png)
![Fishing](assets/fishing.png)
![Talking to NPCs in the Town](assets/npc_dialogue.png)

## Setup

If you just want to play, you can find a compiled pdx under the [releases section](https://github.com/Jacky161/Farmbound/releases). This can be used with the Playdate Simulator or the actual console. To install the game on the console, please refer to Panic's [official instructions for sideloading games](https://help.play.date/games/sideloading/).

## Playdate Development Tips

Please check the [development documentation](docs/DEV.md) for my development tips on working with the Playdate for Lua games.

## License

This project is licensed under the MIT license with some notable exceptions as follows.

- [source/code/helpers/worldloader.lua](source/code/helpers/worldloader.lua) is licensed under the BSD Zero Clause License. This is heavily modified from `Examples/Level 1-1/Source/levelLoader.lua` file in the Playdate SDK. See the file for more details on the license.
- [source/libraries/pulp-audio/pulp-audio.lua](source/libraries/pulp-audio/pulp-audio.lua) is obtained from the [Pulp editor](https://play.date/pulp) to use Pulp Music & SFX in lua games. I am not aware of the license for this file.
- The player sprites are obtained from [Mystic Woods by Game Endeavor](https://game-endeavor.itch.io/mystic-woods)
- The undead sprite is obtained from [16x16 Dungeon Tileset by 0x72](https://0x72.itch.io/16x16-dungeon-tileset)
- The paths, and nature sprites are obtained from [Bountiful Bits by VEXED](https://v3x3d.itch.io/bountiful-bits)
- The house on the farm is not created by me. The original source appears to be gone, but if you are the original author, please feel free to reach out so you can be credited.
