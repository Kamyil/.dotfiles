-- colors/browny.lua
-- Backup of MHFU Pokke Village colorscheme (warm brown wood variant)
-- Based on actual MHFU UI colors, muted paper-pastel style

local c = {
    -- HUD Accent colors (from actual MHFU HUD - for UI accents)
    hud_blue      = "#304651",   -- dark blue item slots
    hud_blue_dark = "#1A242C",   -- shadow of blue slots
    hud_green     = "#2E3838",   -- dark green background texture
    hud_green_dark = "#242A27",  -- shadow of green texture

    -- Backgrounds: warm wood tones (guild hall / quest board)
    bg          = "#1a1816",   -- dark wood
    bg_alt      = "#22201c",   -- slightly lighter wood
    bg_float    = "#22201c",   -- same as bg_alt for floats (wood)
    gutter      = "#16140f",   -- darkest wood shadow
    cursorline  = "#2E3838",   -- HUD green for cursor line

    -- Foregrounds: parchment/cream text (like quest menu text)
    fg          = "#d4c8b0",   -- cream parchment
    fg_dim      = "#9a8a70",   -- faded text
    fg_dark     = "#5a4a3a",   -- very faded

    -- MHFU UI Colors (muted, paper-pastel)

    -- Quest Menu Blue/Teal (the iconic MHFU menu color)
    quest_blue  = "#6a8a9a",   -- muted teal-blue (functions)
    rathalos_red = "#AD5958",  -- rathalos red (imports)

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
    diff_change = "#2a3038",   -- blueish tint (HUD blue hint)
    diff_delete = "#382828",   -- reddish tint
}

-- MHFU-style border options (pick one to use in your plugin configs)
-- Access via: require('colors.mhfu-pokke').borders.rough
local borders = {
    -- Option 1: Dotted/dashed (rough feel)
    dashed = { "┌", "╌", "┐", "╎", "┘", "╌", "└", "╎" },

    -- Option 2: Braille texture (grainy, MHFU zig-zag approximation)
    braille = { "⣏", "⣉", "⣹", "⣿", "⣹", "⣉", "⣏", "⣿" },

    -- Option 3: Block shading (thick frame)
    blocks = { "▛", "▀", "▜", "▐", "▟", "▄", "▙", "▌" },

    -- Option 4: Stippled/noise
    stippled = { "░", "░", "░", "░", "░", "░", "░", "░" },

    -- Option 5: Medium shade
    shaded = { "▒", "▒", "▒", "▒", "▒", "▒", "▒", "▒" },

    -- Option 6: Diagonal corners
    diagonal = { "╱", "─", "╲", "│", "╱", "─", "╲", "│" },

    -- Option 7: Standard rounded (fallback)
    rounded = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
}

local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end

vim.g.colors_name = "browny"

-----------------------------------------------------------------------
-- UI Elements
-----------------------------------------------------------------------
hi("Normal",       { fg = c.fg, bg = c.bg })
hi("NormalNC",     { fg = c.fg_dim, bg = c.bg })
hi("NormalFloat",  { fg = c.fg, bg = c.bg_float })
hi("FloatBorder",  { fg = c.border, bg = c.bg_float })
hi("FloatTitle",   { fg = c.wood_light, bg = c.bg_float, bold = true })

hi("SignColumn",   { fg = c.fg_dim, bg = c.bg })
hi("ColorColumn",  { bg = c.bg_alt })
hi("CursorLine",   { bg = c.cursorline })
hi("CursorColumn", { bg = c.cursorline })
hi("CursorLineNr", { fg = c.stamina_gold, bold = true })
hi("LineNr",       { fg = c.fg_dark })
hi("VertSplit",    { fg = c.border, bg = c.bg })
hi("WinSeparator", { fg = c.border, bg = c.bg })
hi("EndOfBuffer",  { fg = c.bg_alt })

-- Statusline / Tabline
hi("StatusLine",   { fg = c.fg, bg = c.bg_alt })
hi("StatusLineNC", { fg = c.fg_dark, bg = c.bg_alt })
hi("TabLine",      { fg = c.fg_dim, bg = c.bg_alt })
hi("TabLineSel",   { fg = c.bg, bg = c.wood_brown, bold = true })
hi("TabLineFill",  { fg = c.fg_dim, bg = c.bg })
hi("WinBar",       { fg = c.fg_dim, bg = c.bg })
hi("WinBarNC",     { fg = c.fg_dark, bg = c.bg })

-- Completion menu
hi("Pmenu",        { fg = c.fg, bg = c.bg_float })
hi("PmenuSel",     { fg = c.bg, bg = c.wood_brown })
hi("PmenuSbar",    { bg = c.bg_alt })
hi("PmenuThumb",   { bg = c.border })

-- Visual / Selection
hi("Visual",       { bg = c.selection })
hi("VisualNOS",    { bg = c.selection })

-- Search
hi("Search",       { fg = c.bg, bg = c.wood_light })
hi("IncSearch",    { fg = c.bg, bg = c.felyne_orange, bold = true })
hi("CurSearch",    { fg = c.bg, bg = c.stamina_gold, bold = true })
hi("Substitute",   { fg = c.bg, bg = c.meat_red })

-- Matching
hi("MatchParen",   { fg = c.stamina_gold, bold = true, underline = true })

-- Messages
hi("Title",        { fg = c.wood_light, bold = true })
hi("Directory",    { fg = c.quest_blue, bold = true })
hi("ErrorMsg",     { fg = c.meat_red, bold = true })
hi("WarningMsg",   { fg = c.felyne_orange })
hi("MoreMsg",      { fg = c.health_green })
hi("Question",     { fg = c.stamina_gold })
hi("ModeMsg",      { fg = c.fg_dim })

-- Folding
hi("Folded",       { fg = c.fg_dim, bg = c.bg_alt, italic = true })
hi("FoldColumn",   { fg = c.fg_dark, bg = c.bg })

-- Diff
hi("DiffAdd",      { bg = c.diff_add })
hi("DiffChange",   { bg = c.diff_change })
hi("DiffDelete",   { fg = c.meat_red, bg = c.diff_delete })
hi("DiffText",     { fg = c.stamina_gold, bg = c.diff_change, bold = true })

-- Spell
hi("SpellBad",     { undercurl = true, sp = c.meat_red })
hi("SpellCap",     { undercurl = true, sp = c.stamina_gold })
hi("SpellLocal",   { undercurl = true, sp = c.quest_blue })
hi("SpellRare",    { undercurl = true, sp = c.rare_purple })

-- Misc
hi("NonText",      { fg = c.bg_alt })
hi("SpecialKey",   { fg = c.fg_dark })
hi("Whitespace",   { fg = c.bg_alt })
hi("Conceal",      { fg = c.fg_dark })

-----------------------------------------------------------------------
-- Syntax Highlighting - MHFU UI Colors
-----------------------------------------------------------------------
hi("Comment",      { fg = c.fg_dark, italic = true })  -- faded notes

hi("Constant",     { fg = c.ice_pale })                -- pale ice
hi("String",       { fg = c.health_green })            -- health bar green
hi("Character",    { fg = c.health_green })
hi("Number",       { fg = c.stamina_gold })            -- stamina bar yellow
hi("Boolean",      { fg = c.felyne_orange })           -- felyne kitchen warmth
hi("Float",        { fg = c.stamina_gold })

hi("Identifier",   { fg = c.fg })                      -- parchment text
hi("Function",     { fg = c.quest_blue })              -- quest menu blue

hi("Statement",    { fg = c.wood_brown })              -- wood frame brown
hi("Conditional",  { fg = c.wood_brown })
hi("Repeat",       { fg = c.wood_brown })
hi("Label",        { fg = c.felyne_orange })           -- warm accent
hi("Operator",     { fg = c.wood_dark })               -- dark wood
hi("Keyword",      { fg = c.wood_brown })
hi("Exception",    { fg = c.meat_red })                -- well-done steak red

hi("PreProc",      { fg = c.rathalos_red })             -- quest panel blue
hi("Include",      { fg = c.rathalos_red })
hi("Define",       { fg = c.rathalos_red })
hi("Macro",        { fg = c.rathalos_red })
hi("PreCondit",    { fg = c.rathalos_red })

hi("Type",         { fg = c.snow_blue })               -- pokke snow blue
hi("StorageClass", { fg = c.wood_brown })
hi("Structure",    { fg = c.snow_blue })
hi("Typedef",      { fg = c.snow_blue })

hi("Special",      { fg = c.rare_purple })             -- rare item glow
hi("SpecialChar",  { fg = c.felyne_orange })
hi("Tag",          { fg = c.rare_purple })
hi("Delimiter",    { fg = c.wood_dark })
hi("SpecialComment", { fg = c.fg_dim, bold = true })
hi("Debug",        { fg = c.meat_red })

hi("Underlined",   { fg = c.quest_blue, underline = true })
hi("Ignore",       { fg = c.fg_dark })
hi("Error",        { fg = c.meat_red, bold = true })
hi("Todo",         { fg = c.bg, bg = c.stamina_gold, bold = true })

-----------------------------------------------------------------------
-- Diagnostics (LSP)
-----------------------------------------------------------------------
hi("DiagnosticError", { fg = c.meat_red })
hi("DiagnosticWarn",  { fg = c.felyne_orange })
hi("DiagnosticInfo",  { fg = c.quest_blue })
hi("DiagnosticHint",  { fg = c.health_green })
hi("DiagnosticOk",    { fg = c.health_green })

hi("DiagnosticVirtualTextError", { fg = c.meat_red, italic = true })
hi("DiagnosticVirtualTextWarn",  { fg = c.felyne_orange, italic = true })
hi("DiagnosticVirtualTextInfo",  { fg = c.quest_blue, italic = true })
hi("DiagnosticVirtualTextHint",  { fg = c.health_green, italic = true })

hi("DiagnosticUnderlineError", { undercurl = true, sp = c.meat_red })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.felyne_orange })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.quest_blue })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.health_green })

-----------------------------------------------------------------------
-- LSP Highlights
-----------------------------------------------------------------------
hi("LspReferenceText",  { bg = c.selection })
hi("LspReferenceRead",  { bg = c.selection })
hi("LspReferenceWrite", { bg = c.selection, bold = true })
hi("LspSignatureActiveParameter", { fg = c.wood_light, bold = true })
hi("LspCodeLens",       { fg = c.fg_dark, italic = true })
hi("LspInlayHint",      { fg = c.fg_dark, italic = true })

-----------------------------------------------------------------------
-- Treesitter Highlights
-----------------------------------------------------------------------
-- Comments
hi("@comment",               { fg = c.fg_dark, italic = true })
hi("@comment.documentation", { fg = c.fg_dim, italic = true })
hi("@comment.error",         { fg = c.meat_red, bold = true })
hi("@comment.warning",       { fg = c.felyne_orange, bold = true })
hi("@comment.todo",          { fg = c.bg, bg = c.wood_light, bold = true })
hi("@comment.note",          { fg = c.quest_blue, bold = true })

-- Literals
hi("@string",          { fg = c.health_green })
hi("@string.escape",   { fg = c.felyne_orange })
hi("@string.regex",    { fg = c.rare_purple })
hi("@string.special",  { fg = c.rare_purple })
hi("@character",       { fg = c.health_green })
hi("@character.special", { fg = c.felyne_orange })
hi("@number",          { fg = c.stamina_gold })
hi("@number.float",    { fg = c.stamina_gold })
hi("@boolean",         { fg = c.felyne_orange })

-- Identifiers
hi("@variable",          { fg = c.fg })
hi("@variable.builtin",  { fg = c.ice_pale })
hi("@variable.parameter", { fg = c.fg_dim })
hi("@variable.member",   { fg = c.fg })

hi("@constant",          { fg = c.ice_pale })
hi("@constant.builtin",  { fg = c.ice_pale })
hi("@constant.macro",    { fg = c.rathalos_red })

hi("@module",            { fg = c.rathalos_red })
hi("@label",             { fg = c.felyne_orange })

-- Functions - quest menu blue
hi("@function",          { fg = c.quest_blue })
hi("@function.builtin",  { fg = c.quest_blue })
hi("@function.call",     { fg = c.quest_blue })
hi("@function.macro",    { fg = c.rathalos_red })
hi("@function.method",   { fg = c.quest_blue })
hi("@function.method.call", { fg = c.quest_blue })
hi("@constructor",       { fg = c.snow_blue })

-- Keywords - wood brown
hi("@keyword",           { fg = c.wood_brown })
hi("@keyword.coroutine", { fg = c.wood_brown })
hi("@keyword.function",  { fg = c.wood_brown })
hi("@keyword.operator",  { fg = c.wood_dark })
hi("@keyword.import",    { fg = c.rathalos_red })
hi("@keyword.type",      { fg = c.wood_brown })
hi("@keyword.modifier",  { fg = c.wood_brown })
hi("@keyword.repeat",    { fg = c.wood_brown })
hi("@keyword.return",    { fg = c.wood_brown })
hi("@keyword.exception", { fg = c.meat_red })
hi("@keyword.conditional", { fg = c.wood_brown })

-- Operators / Punctuation
hi("@operator",          { fg = c.wood_dark })
hi("@punctuation.bracket", { fg = c.fg_dim })
hi("@punctuation.delimiter", { fg = c.wood_dark })
hi("@punctuation.special", { fg = c.rare_purple })

-- Types - snow blue
hi("@type",              { fg = c.snow_blue })
hi("@type.builtin",      { fg = c.snow_blue })
hi("@type.definition",   { fg = c.snow_blue })
hi("@type.qualifier",    { fg = c.wood_brown })

hi("@attribute",         { fg = c.rathalos_red })
hi("@attribute.builtin", { fg = c.rathalos_red })
hi("@property",          { fg = c.fg })

-- Tags (HTML/JSX)
hi("@tag",               { fg = c.rare_purple })
hi("@tag.builtin",       { fg = c.rare_purple })
hi("@tag.attribute",     { fg = c.felyne_orange })
hi("@tag.delimiter",     { fg = c.wood_dark })

-- Markup
hi("@markup.heading",    { fg = c.wood_light, bold = true })
hi("@markup.heading.1",  { fg = c.wood_light, bold = true })
hi("@markup.heading.2",  { fg = c.wood_light, bold = true })
hi("@markup.heading.3",  { fg = c.felyne_orange, bold = true })
hi("@markup.heading.4",  { fg = c.felyne_orange })
hi("@markup.heading.5",  { fg = c.wood_brown })
hi("@markup.heading.6",  { fg = c.wood_brown })

hi("@markup.strong",     { bold = true })
hi("@markup.italic",     { italic = true })
hi("@markup.strikethrough", { strikethrough = true })
hi("@markup.underline",  { underline = true })

hi("@markup.quote",      { fg = c.fg_dim, italic = true })
hi("@markup.math",       { fg = c.quest_blue })
hi("@markup.link",       { fg = c.quest_blue, underline = true })
hi("@markup.link.label", { fg = c.quest_blue })
hi("@markup.link.url",   { fg = c.quest_blue, underline = true })
hi("@markup.raw",        { fg = c.health_green })
hi("@markup.raw.block",  { fg = c.health_green })
hi("@markup.list",       { fg = c.wood_brown })
hi("@markup.list.checked", { fg = c.health_green })
hi("@markup.list.unchecked", { fg = c.fg_dark })

-- Diff
hi("@diff.plus",         { fg = c.health_green })
hi("@diff.minus",        { fg = c.meat_red })
hi("@diff.delta",        { fg = c.quest_blue })

-----------------------------------------------------------------------
-- Git Signs
-----------------------------------------------------------------------
hi("GitSignsAdd",          { fg = c.health_green })
hi("GitSignsChange",       { fg = c.quest_blue })
hi("GitSignsDelete",       { fg = c.meat_red })
hi("GitSignsAddNr",        { fg = c.health_green })
hi("GitSignsChangeNr",     { fg = c.quest_blue })
hi("GitSignsDeleteNr",     { fg = c.meat_red })
hi("GitSignsAddLn",        { bg = c.diff_add })
hi("GitSignsChangeLn",     { bg = c.diff_change })
hi("GitSignsDeleteLn",     { bg = c.diff_delete })

-----------------------------------------------------------------------
-- Indent Blankline
-----------------------------------------------------------------------
hi("IblIndent",            { fg = c.bg_alt })
hi("IblScope",             { fg = c.border })

-----------------------------------------------------------------------
-- Telescope / FZF
-----------------------------------------------------------------------
hi("TelescopeNormal",      { fg = c.fg, bg = c.bg_float })
hi("TelescopeBorder",      { fg = c.border, bg = c.bg_float })
hi("TelescopeTitle",       { fg = c.wood_light, bold = true })
hi("TelescopePromptNormal", { fg = c.fg, bg = c.bg_alt })
hi("TelescopePromptBorder", { fg = c.border, bg = c.bg_alt })
hi("TelescopePromptTitle", { fg = c.wood_light, bold = true })
hi("TelescopeResultsNormal", { fg = c.fg, bg = c.bg_float })
hi("TelescopeSelection",   { bg = c.selection })
hi("TelescopeMatching",    { fg = c.stamina_gold, bold = true })

-----------------------------------------------------------------------
-- NvimTree / Oil
-----------------------------------------------------------------------
hi("NvimTreeNormal",       { fg = c.fg, bg = c.bg })
hi("NvimTreeRootFolder",   { fg = c.wood_light, bold = true })
hi("NvimTreeFolderName",   { fg = c.quest_blue })
hi("NvimTreeFolderIcon",   { fg = c.wood_brown })
hi("NvimTreeOpenedFolderName", { fg = c.quest_blue, bold = true })
hi("NvimTreeEmptyFolderName", { fg = c.fg_dim })
hi("NvimTreeSymlink",      { fg = c.quest_blue })
hi("NvimTreeExecFile",     { fg = c.health_green, bold = true })
hi("NvimTreeSpecialFile",  { fg = c.rare_purple })
hi("NvimTreeIndentMarker", { fg = c.bg_alt })
hi("NvimTreeGitDirty",     { fg = c.felyne_orange })
hi("NvimTreeGitNew",       { fg = c.health_green })
hi("NvimTreeGitDeleted",   { fg = c.meat_red })

hi("OilDir",               { fg = c.quest_blue, bold = true })
hi("OilFile",              { fg = c.fg })

-----------------------------------------------------------------------
-- Which-Key
-----------------------------------------------------------------------
hi("WhichKey",             { fg = c.wood_light })
hi("WhichKeyGroup",        { fg = c.quest_blue })
hi("WhichKeyDesc",         { fg = c.fg_dim })
hi("WhichKeySeparator",    { fg = c.fg_dark })
hi("WhichKeyFloat",        { bg = c.bg_float })
hi("WhichKeyBorder",       { fg = c.border, bg = c.bg_float })

-----------------------------------------------------------------------
-- Blink.cmp / Completion
-----------------------------------------------------------------------
hi("BlinkCmpMenu",         { fg = c.fg, bg = c.bg_float })
hi("BlinkCmpMenuBorder",   { fg = c.border, bg = c.bg_float })
hi("BlinkCmpMenuSelection", { bg = c.selection })
hi("BlinkCmpLabel",        { fg = c.fg })
hi("BlinkCmpLabelMatch",   { fg = c.stamina_gold, bold = true })
hi("BlinkCmpKind",         { fg = c.fg_dim })

hi("BlinkCmpKindFunction", { fg = c.quest_blue })
hi("BlinkCmpKindMethod",   { fg = c.quest_blue })
hi("BlinkCmpKindVariable", { fg = c.fg })
hi("BlinkCmpKindKeyword",  { fg = c.wood_brown })
hi("BlinkCmpKindText",     { fg = c.fg_dim })
hi("BlinkCmpKindSnippet",  { fg = c.rare_purple })
hi("BlinkCmpKindClass",    { fg = c.snow_blue })
hi("BlinkCmpKindInterface", { fg = c.snow_blue })
hi("BlinkCmpKindModule",   { fg = c.rathalos_red })
hi("BlinkCmpKindProperty", { fg = c.fg })
hi("BlinkCmpKindUnit",     { fg = c.stamina_gold })
hi("BlinkCmpKindValue",    { fg = c.ice_pale })
hi("BlinkCmpKindEnum",     { fg = c.snow_blue })
hi("BlinkCmpKindColor",    { fg = c.rare_purple })
hi("BlinkCmpKindFile",     { fg = c.fg })
hi("BlinkCmpKindFolder",   { fg = c.quest_blue })
hi("BlinkCmpKindConstant", { fg = c.ice_pale })
hi("BlinkCmpKindField",    { fg = c.fg })
hi("BlinkCmpKindStruct",   { fg = c.snow_blue })

-----------------------------------------------------------------------
-- Harpoon
-----------------------------------------------------------------------
hi("HarpoonActive",        { fg = c.wood_light, bold = true })
hi("HarpoonInactive",      { fg = c.fg_dark })

-----------------------------------------------------------------------
-- Todo Comments
-----------------------------------------------------------------------
hi("TodoBgFIX",            { fg = c.bg, bg = c.meat_red, bold = true })
hi("TodoBgTODO",           { fg = c.bg, bg = c.wood_light, bold = true })
hi("TodoBgHACK",           { fg = c.bg, bg = c.felyne_orange, bold = true })
hi("TodoBgWARN",           { fg = c.bg, bg = c.felyne_orange, bold = true })
hi("TodoBgNOTE",           { fg = c.bg, bg = c.quest_blue, bold = true })
hi("TodoBgPERF",           { fg = c.bg, bg = c.rare_purple, bold = true })

hi("TodoFgFIX",            { fg = c.meat_red })
hi("TodoFgTODO",           { fg = c.wood_light })
hi("TodoFgHACK",           { fg = c.felyne_orange })
hi("TodoFgWARN",           { fg = c.felyne_orange })
hi("TodoFgNOTE",           { fg = c.quest_blue })
hi("TodoFgPERF",           { fg = c.rare_purple })

-----------------------------------------------------------------------
-- Lazy.nvim
-----------------------------------------------------------------------
hi("LazyButton",           { fg = c.fg, bg = c.bg_alt })
hi("LazyButtonActive",     { fg = c.bg, bg = c.wood_brown, bold = true })
hi("LazyH1",               { fg = c.bg, bg = c.wood_light, bold = true })
hi("LazyH2",               { fg = c.wood_light, bold = true })
hi("LazySpecial",          { fg = c.quest_blue })
hi("LazyCommit",           { fg = c.health_green })
hi("LazyReasonPlugin",     { fg = c.quest_blue })
hi("LazyReasonFt",         { fg = c.wood_brown })
hi("LazyReasonCmd",        { fg = c.quest_blue })
hi("LazyReasonEvent",      { fg = c.rare_purple })
hi("LazyReasonStart",      { fg = c.stamina_gold })

-----------------------------------------------------------------------
-- Barbecue (breadcrumbs)
-----------------------------------------------------------------------
hi("BarbecueDirname",      { fg = c.fg_dark })
hi("BarbecueBasename",     { fg = c.fg_dim, bold = true })
hi("BarbecueSeparator",    { fg = c.fg_dark })
hi("BarbecueContext",      { fg = c.fg_dim })

-----------------------------------------------------------------------
-- Export colors and borders for external use
-- Usage: local mhfu = require('colors.mhfu-pokke')
--        mhfu.colors.quest_blue
--        mhfu.borders.rounded
-----------------------------------------------------------------------
return {
	colors = c,
	borders = borders,
}
