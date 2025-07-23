-- CSGOMovement.lua
-- ModuleScript: Core CS:GO-style bunny-hop & air-strafe physics for Roblox
-- Place this ModuleScript in ReplicatedStorage.
--
-- This module provides all the movement math for the system. Tweak the constants below to adjust feel.

local CSGOMovement = {}

---------------------------------------------------------------------
-- Tunable constants (edit these to balance movement) --------------
---------------------------------------------------------------------
-- These values are based on Source engine defaults, converted to Roblox units (studs).
-- See the README for a quick reference table.
---------------------------------------------------------------------

CSGOMovement.MAX_SPEED       = 23           -- ~250 u/s converted to studs
CSGOMovement.ACCELERATE      = 5.5          -- sv_accelerate
CSGOMovement.AIR_ACCELERATE  = 100          -- High for auto-bhop feel
CSGOMovement.AIR_CAP         = 10           -- Max air control speed
CSGOMovement.FRICTION        = 4            -- sv_friction
CSGOMovement.STOP_SPEED      = 7.5          -- 80 u/s → studs
CSGOMovement.CROUCH_SPEED_MULT = 0.33       -- Speed multiplier when crouched
CSGOMovement.ENABLE_JUMP_CAP   = false      -- Set true to limit bhop speed
CSGOMovement.JUMP_CAP_MULT     = 100        -- Only used if ENABLE_JUMP_CAP is true
CSGOMovement.GRAVITY         = workspace.Gravity  -- Set by InitMovement.server.lua
CSGOMovement.JUMP_HEIGHT     = 4.1          -- 45 u → studs

---------------------------------------------------------------------
-- Utility math helpers ---------------------------------------------
---------------------------------------------------------------------
local ZERO = Vector3.new()
local UP   = Vector3.new(0,1,0)
local function dot(a,b) return a:Dot(b) end

---------------------------------------------------------------------
-- Public physics helpers -------------------------------------------
---------------------------------------------------------------------

-- Clamp horizontal speed (used for jump cap)
function CSGOMovement.ClampHorizontalSpeed(vel)
    if not CSGOMovement.ENABLE_JUMP_CAP then return vel end
    local horiz = Vector3.new(vel.X, 0, vel.Z)
    local speed = horiz.Magnitude
    local maxSpeed = CSGOMovement.MAX_SPEED * CSGOMovement.JUMP_CAP_MULT
    if speed > maxSpeed then
        local scale = maxSpeed / speed
        vel = Vector3.new(horiz.X*scale, vel.Y, horiz.Z*scale)
    end
    return vel
end

-- Ground acceleration (matches Valve Accelerate logic)
function CSGOMovement.Accelerate(vel, wishDir, wishSpeed, dt)
    local curSpeed = dot(vel, wishDir)
    local addSpeed = wishSpeed - curSpeed
    if addSpeed <= 0 then return vel end
    local accelSpeed = CSGOMovement.ACCELERATE * wishSpeed * dt
    if accelSpeed > addSpeed then accelSpeed = addSpeed end
    return vel + wishDir * accelSpeed
end

-- Air acceleration (Valve AirAccelerate)
function CSGOMovement.AirAccelerate(vel, wishDir, wishSpeed, dt)
    if wishSpeed > CSGOMovement.AIR_CAP then
        wishSpeed = CSGOMovement.AIR_CAP
    end
    local curSpeed = dot(vel, wishDir)
    local addSpeed = wishSpeed - curSpeed
    if addSpeed <= 0 then return vel end
    local accelSpeed = CSGOMovement.AIR_ACCELERATE * wishSpeed * dt
    if accelSpeed > addSpeed then accelSpeed = addSpeed end
    return vel + wishDir * accelSpeed
end

-- Ground friction (Valve Friction)
function CSGOMovement.ApplyFriction(vel, dt)
    local speed = vel.Magnitude
    if speed < 0.1 then return ZERO end
    local control = math.max(speed, CSGOMovement.STOP_SPEED)
    local drop = control * CSGOMovement.FRICTION * dt
    local newSpeed = math.max(speed - drop, 0)
    if newSpeed == speed then return vel end
    return vel * (newSpeed / speed)
end

-- Horizontal-only friction (ignores Y component)
function CSGOMovement.ApplyGroundFriction(vel, dt)
    local horiz = Vector3.new(vel.X, 0, vel.Z)
    local speed = horiz.Magnitude
    if speed < 0.1 then return vel end
    local control = math.max(speed, CSGOMovement.STOP_SPEED)
    local drop = control * CSGOMovement.FRICTION * dt
    local newSpeed = math.max(speed - drop, 0)
    if newSpeed ~= speed then
        local scale = newSpeed / speed
        horiz = horiz * scale
    end
    return Vector3.new(horiz.X, vel.Y, horiz.Z)
end

-- Gravity application
function CSGOMovement.ApplyGravity(vel, dt)
    return vel + Vector3.new(0, -CSGOMovement.GRAVITY * dt, 0)
end

-- Jump impulse velocity (v = sqrt(2gh))
function CSGOMovement.JumpImpulse()
    return math.sqrt(2 * CSGOMovement.GRAVITY * CSGOMovement.JUMP_HEIGHT)
end

return CSGOMovement 