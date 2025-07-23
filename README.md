# Roblox CS:GO-Style Movement System

This repository provides a plug-and-play CS:GO-inspired movement system for Roblox, including bunnyhopping, air-strafing, and friction/acceleration physics.

## Features
- True bunnyhop and air-strafe physics (ported from Source engine)
- Customizable movement constants (speed, acceleration, friction, etc.)
- First-person camera toggle and crouch support

## Quick Start
1. **Copy the files in this folder into your Roblox project:**
   - `CSGOMovement.lua` (ModuleScript, place in ReplicatedStorage)
   - `PlayerController.client.lua` (LocalScript, place in StarterPlayerScripts)
   - `InitMovement.server.lua` (Script, place in ServerScriptService)

2. **Tweak movement constants** in `CSGOMovement.lua` as desired.

3. **Play!**
   - WASD to move, Space to jump (auto-bhop supported), Left Ctrl to crouch, P to toggle first-person.

## File Placement
| File                        | Where to put it                |
|-----------------------------|--------------------------------|
| CSGOMovement.lua            | ReplicatedStorage (ModuleScript)|
| PlayerController.client.lua | StarterPlayerScripts (LocalScript) |
| InitMovement.server.lua     | ServerScriptService (Script)   |

## Credits
- Movement logic adapted from Valve's Source Engine (CS:GO)
- Roblox port and scripting by cyfrinn

## License
MIT or similar. See LICENSE file. 