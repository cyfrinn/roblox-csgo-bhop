# 🎮 Roblox CS:GO-Style Movement System

<div align="center">

![Lua](https://img.shields.io/badge/Lua-100%25-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Roblox-red.svg)
![Source Engine](https://img.shields.io/badge/inspired%20by-Source%20Engine-orange.svg)

**Authentic CS:GO movement physics recreated for Roblox**

Experience true bunnyhopping, air-strafing, and Source engine movement mechanics in your Roblox games.

[Features](#-features) • [Demo](#-demo) • [Quick Start](#-quick-start) • [Documentation](#-documentation)

</div>

---

## 📖 Overview

A plug-and-play movement system that brings authentic Counter-Strike: Global Offensive movement physics to Roblox. This system faithfully recreates Valve's Source engine movement mechanics, including bunnyhopping, air-strafing, and acceleration/friction physics.

### Why This System?

- 🎯 **Authentic Feel** - Ported directly from Source engine physics
- 🔧 **Plug & Play** - Just copy 3 files and you're done
- ⚙️ **Fully Customizable** - Tweak every movement constant
- 🏃 **Auto-Bhop** - Hold space for continuous bunnyhopping
- 📹 **First-Person Ready** - Built-in FPS camera mode
- 🪶 **Lightweight** - Only 3 scripts, ~300 lines total

---

## ✨ Features

### 🏃 Movement Mechanics
- **Bunnyhopping** - True Source-style bhop with speed preservation
- **Air-Strafing** - Gain speed by strafing mid-air
- **Ground Friction** - Authentic sv_friction implementation
- **Speed Capping** - Optional jump speed limits

### 🎮 Player Controls
- **WASD Movement** - Camera-relative movement
- **Auto-Bhop** - Hold Space for continuous jumping
- **Crouching** - Left Ctrl to crouch (33% speed)
- **Camera Toggle** - Press P for first/third person

### ⚙️ Technical Features
- **Physics-Based** - Uses AssemblyLinearVelocity for smooth movement
- **Frame-Independent** - Delta-time based calculations
- **Modular Design** - Clean separation between physics and input
- **Server Authority** - Gravity controlled server-side

---

## 🎬 Demo

### Controls

```
┌─────────────────────────────────────────┐
│   W                                     │
│ A S D    - Move (camera-relative)       │
│ SPACE    - Jump (hold for auto-bhop)    │
│ L-CTRL   - Crouch (33% speed)           │
│ P        - Toggle first/third person    │
└─────────────────────────────────────────┘
```

### Movement Flow

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Grounded   │    │   In Air     │    │   Landing    │
│              │    │              │    │              │
│ • Friction   │───▶│ • Air Accel  │───▶│ • No Friction│
│ • Ground     │    │ • Gravity    │    │ • Auto-bhop  │
│   Accel      │    │ • Strafing   │    │   Queued     │
└──────────────┘    └──────────────┘    └──────┬───────┘
       ▲                                       │
       └───────────────────────────────────────┘
```

### Speed Building Technique

1. **Start running** - Build up to max ground speed
2. **Jump** - Momentum is preserved
3. **Strafe + Mouse** - Turn mouse while holding A or D
4. **Land & Jump** - Hold Space for instant re-jump
5. **Repeat** - Each perfect bhop maintains/gains speed

---

## 🚀 Quick Start

### Prerequisites

- Roblox Studio
- Basic knowledge of Roblox scripting locations

### Installation

**Step 1:** Clone or download the repository

```bash
git clone https://github.com/cyfrinn/roblox-csgo-bhop.git
```

**Step 2:** Copy scripts to your Roblox project

| File | Destination | Script Type |
|------|-------------|-------------|
| `CSGOMovement.lua` | ReplicatedStorage | ModuleScript |
| `PlayerController.client.lua` | StarterPlayerScripts | LocalScript |
| `InitMovement.server.lua` | ServerScriptService | Script |

**Step 3:** Play and enjoy!

### Quick Setup in Studio

1. Open your Roblox game in Studio
2. Create a **ModuleScript** in `ReplicatedStorage` named `CSGOMovement`
3. Create a **LocalScript** in `StarterPlayer > StarterPlayerScripts` named `PlayerController`
4. Create a **Script** in `ServerScriptService` named `InitMovement`
5. Copy the contents from each file
6. Hit **Play**!

---

## 📚 Documentation

### File Structure

```
roblox-csgo-bhop/
├── CSGOMovement.lua           # Core physics module
├── PlayerController.client.lua # Input handling & main loop
├── InitMovement.server.lua     # Server-side gravity setup
└── README.md                   # This file
```

### Movement Constants

All tunable values are in `CSGOMovement.lua`:

| Constant | Default | Description |
|----------|---------|-------------|
| `MAX_SPEED` | 23 | Maximum ground speed (~250 Source units) |
| `ACCELERATE` | 5.5 | Ground acceleration (sv_accelerate) |
| `AIR_ACCELERATE` | 100 | Air acceleration for bhop feel |
| `AIR_CAP` | 10 | Maximum air control speed |
| `FRICTION` | 4 | Ground friction (sv_friction) |
| `STOP_SPEED` | 7.5 | Minimum speed before stopping |
| `CROUCH_SPEED_MULT` | 0.33 | Crouch speed multiplier |
| `JUMP_HEIGHT` | 4.1 | Jump height in studs (~45 Source units) |
| `GRAVITY` | 73 | Gravity (from workspace) |

### Source Engine Conversion

```
Source Units → Roblox Studs
─────────────────────────────
250 u/s      → 23 studs/s    (max speed)
80 u/s       → 7.5 studs/s   (stop speed)
45 u         → 4.1 studs     (jump height)
800 u/s²     → 73 studs/s²   (gravity)
```

### Physics Functions

| Function | Purpose |
|----------|---------|
| `Accelerate()` | Ground movement acceleration |
| `AirAccelerate()` | Air-strafe acceleration |
| `ApplyFriction()` | Full velocity friction |
| `ApplyGroundFriction()` | Horizontal-only friction |
| `ApplyGravity()` | Gravity application |
| `JumpImpulse()` | Calculate jump velocity |
| `ClampHorizontalSpeed()` | Optional speed cap |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SERVER SIDE                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  InitMovement.server.lua                             │    │
│  │  • Sets workspace.Gravity = 73                       │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    CLIENT SIDE                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  PlayerController.client.lua                         │    │
│  │  • Input handling (WASD, Space, Ctrl, P)            │    │
│  │  • Camera management                                 │    │
│  │  • Main simulation loop (RunService.Heartbeat)      │    │
│  │  • Ground detection                                  │    │
│  └──────────────────────────┬──────────────────────────┘    │
│                             │                                │
│                             ▼                                │
│  ┌─────────��───────────────────────────────────────────┐    │
│  │  CSGOMovement.lua (ModuleScript)                     │    │
│  │  • Movement constants                                │    │
│  │  • Acceleration functions                            │    │
│  │  • Friction calculations                             │    │
│  │  • Gravity & jump physics                            │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

### Core
- **Luau** - Roblox's Lua variant
- **RunService** - Frame-based simulation
- **UserInputService** - Keyboard input handling

### Physics
- **AssemblyLinearVelocity** - Direct velocity control
- **Vector3** - 3D math operations
- **CFrame** - Position and rotation

### Services Used
- **Players** - Player management
- **ReplicatedStorage** - Shared module storage
- **Workspace** - Physics settings

---

## 📊 Performance

| Metric | Value |
|--------|-------|
| Script Count | 3 files |
| Total Lines | ~300 LOC |
| Memory Overhead | Minimal |
| Frame Rate Impact | <1ms per frame |
| Network Traffic | None (client-side) |

---

## 🎯 Customization Examples

### Faster Movement (KZ Style)
```lua
CSGOMovement.MAX_SPEED = 30
CSGOMovement.AIR_ACCELERATE = 150
CSGOMovement.FRICTION = 3
```

### Slower, More Realistic
```lua
CSGOMovement.MAX_SPEED = 18
CSGOMovement.AIR_ACCELERATE = 50
CSGOMovement.ENABLE_JUMP_CAP = true
CSGOMovement.JUMP_CAP_MULT = 1.2
```

### Higher Jumps
```lua
CSGOMovement.JUMP_HEIGHT = 6
workspace.Gravity = 60  -- also update server script
```

---

## ⚠️ Known Limitations

1. **Client-Side Movement** - No server-side validation (exploitable)
2. **No Ramp Sliding** - Ramps may behave differently than Source
3. **No Surf Physics** - Surfing not implemented
4. **Character Collisions** - Uses default Roblox character collision

---

## 🚧 Future Improvements

- [ ] Add server-side movement validation
- [ ] Implement surf physics
- [ ] Add ramp/slope handling
- [ ] Create speed HUD display
- [ ] Add strafe trainer mode
- [ ] Implement stamina system (optional)
- [ ] Add sound effects (landing, jumping)

---

## 🤝 Contributing

Contributions are welcome! Feel free to improve the movement system.

### Ideas for Contribution

- [ ] Server-side anti-cheat
- [ ] Surf map physics
- [ ] Long-jump statistics
- [ ] Movement replay system
- [ ] Strafe synchronizer HUD

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/surf-physics`)
3. Commit your changes (`git commit -m 'Add surf physics'`)
4. Push to the branch (`git push origin feature/surf-physics`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Valve Software** - Original Source engine movement system
- **CS:GO Community** - Movement mechanics documentation
- **Roblox** - Platform and physics engine

---

## 📧 Contact

**Project Maintainer:** [@cyfrinn](https://github.com/cyfrinn)

**Project Link:** [https://github.com/cyfrinn/roblox-csgo-bhop](https://github.com/cyfrinn/roblox-csgo-bhop)

---

## 📖 Additional Resources

- [Source Engine Movement Guide](https://developer.valvesoftware.com/wiki/Source_Movement)
- [Roblox Developer Hub](https://create.roblox.com/docs)
- [Bunnyhopping Explained](https://www.youtube.com/results?search_query=csgo+bhop+tutorial)

---

<div align="center">

**⭐ Star this repo if you found it helpful!**

Made with ❤️ for the Roblox bhop community

</div>
