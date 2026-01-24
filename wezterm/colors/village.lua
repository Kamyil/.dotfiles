-- ~/.config/wezterm/colors/village.lua
-- Monster Hunter Freedom Unite – Pokke Village colorscheme
-- Based on actual MHFU UI colors, muted paper-pastel style

local M = {}

M.colors = {
    -- HUD Accent colors (from actual MHFU HUD - for UI accents)
    hud_blue      = "#304651",   -- dark blue item slots
    hud_blue_dark = "#1A242C",   -- shadow of blue slots
    hud_green     = "#2E3838",   -- dark green background texture
    hud_green_dark = "#242A27",  -- shadow of green texture

    -- Backgrounds: warm wood tones (guild hall / quest board)
    bg        = "#1a1816",   -- dark wood
    bg_alt    = "#22201c",   -- slightly lighter wood
    bg_float  = "#22201c",   -- same as bg_alt for floats (wood)
    gutter    = "#16140f",   -- darkest wood shadow

    -- Foregrounds: parchment/cream text (like quest menu text)
    fg        = "#d4c8b0",   -- cream parchment
    fg_dim    = "#9a8a70",   -- faded text
    fg_dark   = "#5a4a3a",   -- very faded

    -- Quest Menu Blue/Teal (the iconic MHFU menu color)
    quest_blue  = "#6a8a9a",   -- muted teal-blue (functions)
    rathalos_red = "#E96961",  -- rathalos red (imports)

    -- Health/Stamina bars
    health_green = "#7a9a6a",  -- health bar green (strings, success)
    stamina_gold = "#c4a860",  -- stamina bar yellow (numbers)

    -- Wooden UI frames / Guild Hall (borders, accents)
    wood_brown  = "#9a7050",   -- wood frame brown (keywords)
    wood_light  = "#b89060",   -- lighter wood (highlights)
    wood_dark   = "#6a5040",   -- darker wood (operators)

    -- Felyne Kitchen / Warm accents
    felyne_orange = "#b8864a", -- warm cooking fire (warnings)
    meat_red    = "#a85a5a",   -- well-done steak red (errors)

    -- Snow/Ice from Pokke Village
    snow_blue   = "#8a9aa8",   -- cold snow reflection (types)
    ice_pale    = "#a0a8b0",   -- pale ice (constants)

    -- Rare/Special items
    rare_purple = "#8a7090",   -- rare item glow (special, tags)

    -- Selection/visual - HUD colors for accents
    selection   = "#2E3838",   -- HUD green for selection
    match       = "#304651",   -- HUD blue for search match
    border      = "#4a5a60",   -- blue-ish border

    -- Diff colors
    diff_add    = "#282e22",   -- greenish tint
    diff_change = "#2a3038",   -- blueish tint
    diff_delete = "#382828",   -- reddish tint
}

return M
