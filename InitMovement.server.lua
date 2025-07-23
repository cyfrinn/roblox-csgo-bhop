-- InitMovement.server.lua
-- Script: Sets global gravity to match CS:GO movement feel.
-- Place this Script in ServerScriptService.
--
-- This ensures the workspace gravity matches the value expected by the movement system.

-- Gravity (studs/s^2) converted from 800 u/s^2 → 73 (rounded for simplicity)
workspace.Gravity = 73

-- Add any additional global movement tweaks here if needed. 