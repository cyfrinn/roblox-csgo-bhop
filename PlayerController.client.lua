-- PlayerController.client.lua
-- LocalScript: Handles player input and applies CS:GO-style movement every frame.
-- Place this LocalScript in StarterPlayerScripts (or StarterCharacterScripts).
--
-- This script disables Roblox's default movement and applies custom movement logic using CSGOMovement.
-- Controls: WASD to move, Space to jump (auto-bhop), Left Ctrl to crouch, P to toggle first-person.

-- Services
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")

-- Module
local Movement = require(game.ReplicatedStorage:WaitForChild("CSGOMovement"))

---------------------------------------------------------------
-- Local state -----------------------------------------------
---------------------------------------------------------------
local player    = Players.LocalPlayer
local character -- populated below
local root      -- HumanoidRootPart
local humanoid

local velocity  = Vector3.new()  -- our custom velocity accumulator
local wasGrounded = false

---------------------------------------------------------------
-- Input handling --------------------------------------------
---------------------------------------------------------------
local inputVector = Vector3.new()
local crouched = false
local originalHipHeight = nil

---------------------------------------------------------------
-- First-person toggle (press P) ------------------------------
---------------------------------------------------------------
local firstPerson = true  -- default to first-person; toggle with P

local function applyCameraMode()
    local cam = workspace.CurrentCamera
    if firstPerson then
        player.CameraMode = Enum.CameraMode.LockFirstPerson
        if cam then cam.FieldOfView = 80 end -- slightly wider FOV like CS:GO
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
    else
        player.CameraMode = Enum.CameraMode.Classic
        if cam then cam.FieldOfView = 70 end -- default Roblox FOV
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.P then
        firstPerson = not firstPerson
        applyCameraMode()
    end
end)

-- Ensure camera mode is restored after character spawns
player.CharacterAdded:Connect(function()
    task.wait(0.1)
    applyCameraMode()
end)

-- Crouch key handling (hold LeftControl)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        crouched = true
        if humanoid then
            if not originalHipHeight then
                originalHipHeight = humanoid.HipHeight
            end
            humanoid.HipHeight = originalHipHeight * 0.5
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        crouched = false
        if humanoid and originalHipHeight then
            humanoid.HipHeight = originalHipHeight
        end
    end
end)

local function recomputeInput()
    local dir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Vector3.new(0, 0, -1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir + Vector3.new(0, 0,  1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir + Vector3.new(-1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new( 1, 0, 0) end
    -- Normalize to keep diagonal speed in check
    if dir.Magnitude > 0 then dir = dir.Unit end
    inputVector = dir
end

local jumpHeld = false
local jumpQueued = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        jumpHeld = true
        jumpQueued = true  -- queue single jump
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.Space then
        jumpHeld = false
    end
end)

---------------------------------------------------------------
-- Ground detection helper -----------------------------------
---------------------------------------------------------------
-- Grounded check via Humanoid FloorMaterial (robust against HipHeight changes)
local function isGrounded()
    return humanoid and humanoid.FloorMaterial ~= Enum.Material.Air
end

---------------------------------------------------------------
-- Character setup -------------------------------------------
---------------------------------------------------------------
local function onCharacterAdded(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")

    -- Disable Roblox default movement but keep Humanoid upright
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.AutoJumpEnabled = false
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    humanoid.AutoRotate = true
    humanoid.PlatformStand = false

    velocity = Vector3.new()
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end

---------------------------------------------------------------
-- Main simulation loop --------------------------------------
---------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    if not (root and humanoid) then return end

    recomputeInput()

    -- Camera-relative movement axes
    local cam = workspace.CurrentCamera
    if not cam then return end
    local look = cam.CFrame.LookVector
    local forward = Vector3.new(look.X, 0, look.Z)
    if forward.Magnitude > 0 then forward = forward.Unit end
    local right = forward:Cross(Vector3.new(0,1,0))

    local wishDir = (forward * -inputVector.Z) + (right * inputVector.X)
    local wishSpeed = Movement.MAX_SPEED * inputVector.Magnitude

    if crouched then
        wishSpeed = wishSpeed * Movement.CROUCH_SPEED_MULT
    end

    local grounded = isGrounded()

    -- Auto-bhop: queue a jump ONLY on landing transition
    if grounded and not wasGrounded and jumpHeld then
        jumpQueued = true
    end

    if grounded then
        -- Prevent sinking only if we’re really falling
        if velocity.Y < -1 then -- instead of < 0
            velocity = Vector3.new(velocity.X, 0, velocity.Z)
        end
        -- Apply friction only if we are NOT about to jump this frame; this mimics
        -- CS:GO autobhop servers where speed isn’t bled off on landing.
        if not jumpQueued then
            velocity = Movement.ApplyGroundFriction(velocity, dt)
        end
        -- Apply acceleration
        velocity = Movement.Accelerate(velocity, wishDir, wishSpeed, dt)
        -- Handle jump
        if jumpQueued then
            velocity = velocity + Vector3.new(0, Movement.JumpImpulse(), 0)
            velocity = Movement.ClampHorizontalSpeed(velocity)
            jumpQueued = false
        end
    else
        -- Air move
        velocity = Movement.AirAccelerate(velocity, wishDir, wishSpeed, dt)
        -- Gravity
        velocity = Movement.ApplyGravity(velocity, dt)
    end

    -- Apply the calculated velocity to the root part (physics-based)
    root.AssemblyLinearVelocity = velocity

    wasGrounded = grounded -- store for next frame

    -- Keep character upright & facing camera yaw
    local faceDir = Vector3.new(look.X, 0, look.Z)
    if faceDir.Magnitude > 0 then
        root.CFrame = CFrame.lookAt(root.Position, root.Position + faceDir)
    end

    -- Eliminate unwanted spin
    root.AssemblyAngularVelocity = Vector3.zero
end) 