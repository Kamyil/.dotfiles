-- colors/mhfu-pokke.lua
-- Monster Hunter Freedom Unite – Pokke Village colorscheme for Neovim
-- "Parchment with ink" aesthetic - like notes in the guild hall

local c = {
    -- Backgrounds: warm dark browns, like aged parchment in dim light
    bg          = "#1c1814",   -- dark warm sepia
    bg_alt      = "#242018",   -- slightly lighter, like paper edge
    bg_float    = "#2a251c",   -- floating windows
    gutter      = "#18140f",   -- darkest margin
    cursorline  = "#23201a",   -- subtle highlight

    -- Foregrounds: ink on parchment
    fg          = "#c8b898",   -- main ink - warm sepia tone
    fg_dim      = "#8a7a68",   -- faded pencil/old ink
    fg_dark     = "#5a4a3a",   -- very faded, like erased marks

    -- "Ink" colors - like different colored inks on parchment
    ink_green   = "#6a8a5a",   -- green ink, faded
    ink_gold    = "#b8a060",   -- gold/ochre ink (brighter)
    ink_red     = "#a06050",   -- faded red ink (sealing wax)
    ink_orange  = "#b08058",   -- burnt sienna (brighter)

    -- Accent inks
    ink_brown   = "#9a7855",   -- brown ink (brighter, more visible)
    ink_sepia   = "#a08562",   -- classic sepia (brighter)

    -- Cool inks - like blue/black fountain pen
    ink_blue    = "#607080",   -- steel blue ink
    ink_teal    = "#5a7a78",   -- teal ink, aged

    -- Special ink - rare purple ink
    ink_purple  = "#786878",   -- faded violet ink

    -- Selection/visual - like highlighted text on parchment
    selection   = "#3a3028",   -- soft highlight
    match       = "#4a3828",   -- search match
    border      = "#3a3228",   -- subtle borders

    -- Diff colors - subtle paper tints
    diff_add    = "#282e22",   -- greenish tint
    diff_change = "#2a2820",   -- yellowish tint
    diff_delete = "#2e2424",   -- reddish tint
}

local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end

vim.g.colors_name = "mhfu-pokke"

-----------------------------------------------------------------------
-- UI Elements
-----------------------------------------------------------------------
hi("Normal",       { fg = c.fg, bg = c.bg })
hi("NormalNC",     { fg = c.fg_dim, bg = c.bg })
hi("NormalFloat",  { fg = c.fg, bg = c.bg_float })
hi("FloatBorder",  { fg = c.border, bg = c.bg_float })
hi("FloatTitle",   { fg = c.ink_sepia, bg = c.bg_float, bold = true })

hi("SignColumn",   { fg = c.fg_dim, bg = c.bg })
hi("ColorColumn",  { bg = c.bg_alt })
hi("CursorLine",   { bg = c.cursorline })
hi("CursorColumn", { bg = c.cursorline })
hi("CursorLineNr", { fg = c.ink_gold, bold = true })
hi("LineNr",       { fg = c.fg_dark })
hi("VertSplit",    { fg = c.border, bg = c.bg })
hi("WinSeparator", { fg = c.border, bg = c.bg })
hi("EndOfBuffer",  { fg = c.bg_alt })

-- Statusline / Tabline - like aged paper headers
hi("StatusLine",   { fg = c.fg, bg = c.bg_alt })
hi("StatusLineNC", { fg = c.fg_dark, bg = c.bg_alt })
hi("TabLine",      { fg = c.fg_dim, bg = c.bg_alt })
hi("TabLineSel",   { fg = c.bg, bg = c.ink_brown, bold = true })
hi("TabLineFill",  { fg = c.fg_dim, bg = c.bg })
hi("WinBar",       { fg = c.fg_dim, bg = c.bg })
hi("WinBarNC",     { fg = c.fg_dark, bg = c.bg })

-- Completion menu
hi("Pmenu",        { fg = c.fg, bg = c.bg_float })
hi("PmenuSel",     { fg = c.bg, bg = c.ink_brown })
hi("PmenuSbar",    { bg = c.bg_alt })
hi("PmenuThumb",   { bg = c.border })

-- Visual / Selection - like highlighting with a marker
hi("Visual",       { bg = c.selection })
hi("VisualNOS",    { bg = c.selection })

-- Search - like circled text
hi("Search",       { fg = c.bg, bg = c.ink_gold })
hi("IncSearch",    { fg = c.bg, bg = c.ink_orange, bold = true })
hi("CurSearch",    { fg = c.bg, bg = c.ink_sepia, bold = true })
hi("Substitute",   { fg = c.bg, bg = c.ink_red })

-- Matching
hi("MatchParen",   { fg = c.ink_gold, bold = true, underline = true })

-- Messages
hi("Title",        { fg = c.ink_sepia, bold = true })
hi("Directory",    { fg = c.ink_blue, bold = true })
hi("ErrorMsg",     { fg = c.ink_red, bold = true })
hi("WarningMsg",   { fg = c.ink_orange })
hi("MoreMsg",      { fg = c.ink_green })
hi("Question",     { fg = c.ink_gold })
hi("ModeMsg",      { fg = c.fg_dim })

-- Folding
hi("Folded",       { fg = c.fg_dim, bg = c.bg_alt, italic = true })
hi("FoldColumn",   { fg = c.fg_dark, bg = c.bg })

-- Diff
hi("DiffAdd",      { bg = c.diff_add })
hi("DiffChange",   { bg = c.diff_change })
hi("DiffDelete",   { fg = c.ink_red, bg = c.diff_delete })
hi("DiffText",     { fg = c.ink_gold, bg = c.diff_change, bold = true })

-- Spell
hi("SpellBad",     { undercurl = true, sp = c.ink_red })
hi("SpellCap",     { undercurl = true, sp = c.ink_gold })
hi("SpellLocal",   { undercurl = true, sp = c.ink_teal })
hi("SpellRare",    { undercurl = true, sp = c.ink_purple })

-- Misc
hi("NonText",      { fg = c.bg_alt })
hi("SpecialKey",   { fg = c.fg_dark })
hi("Whitespace",   { fg = c.bg_alt })
hi("Conceal",      { fg = c.fg_dark })

-----------------------------------------------------------------------
-- Syntax Highlighting - like handwritten notes
-----------------------------------------------------------------------
hi("Comment",      { fg = c.fg_dark, italic = true })  -- faded pencil notes

hi("Constant",     { fg = c.ink_purple })
hi("String",       { fg = c.ink_green })               -- green ink for strings
hi("Character",    { fg = c.ink_green })
hi("Number",       { fg = c.ink_gold })                -- gold ink for numbers
hi("Boolean",      { fg = c.ink_orange })              -- warm orange for booleans
hi("Float",        { fg = c.ink_gold })

hi("Identifier",   { fg = c.fg })                      -- normal ink
hi("Function",     { fg = c.ink_blue })                -- blue ink for functions

hi("Statement",    { fg = c.ink_brown })               -- brown ink for keywords
hi("Conditional",  { fg = c.ink_brown })
hi("Repeat",       { fg = c.ink_brown })
hi("Label",        { fg = c.ink_sepia })
hi("Operator",     { fg = c.fg_dim })                  -- subtle operators
hi("Keyword",      { fg = c.ink_brown })
hi("Exception",    { fg = c.ink_red })

hi("PreProc",      { fg = c.ink_teal })                -- teal for preprocessor
hi("Include",      { fg = c.ink_teal })
hi("Define",       { fg = c.ink_teal })
hi("Macro",        { fg = c.ink_teal })
hi("PreCondit",    { fg = c.ink_teal })

hi("Type",         { fg = c.ink_sepia })               -- sepia for types
hi("StorageClass", { fg = c.ink_brown })
hi("Structure",    { fg = c.ink_sepia })
hi("Typedef",      { fg = c.ink_sepia })

hi("Special",      { fg = c.ink_purple })              -- purple for special
hi("SpecialChar",  { fg = c.ink_orange })
hi("Tag",          { fg = c.ink_blue })
hi("Delimiter",    { fg = c.fg_dim })
hi("SpecialComment", { fg = c.fg_dim, bold = true })
hi("Debug",        { fg = c.ink_red })

hi("Underlined",   { fg = c.ink_teal, underline = true })
hi("Ignore",       { fg = c.fg_dark })
hi("Error",        { fg = c.ink_red, bold = true })
hi("Todo",         { fg = c.bg, bg = c.ink_gold, bold = true })

-----------------------------------------------------------------------
-- Diagnostics (LSP)
-----------------------------------------------------------------------
hi("DiagnosticError", { fg = c.ink_red })
hi("DiagnosticWarn",  { fg = c.ink_orange })
hi("DiagnosticInfo",  { fg = c.ink_teal })
hi("DiagnosticHint",  { fg = c.ink_green })
hi("DiagnosticOk",    { fg = c.ink_green })

hi("DiagnosticVirtualTextError", { fg = c.ink_red, italic = true })
hi("DiagnosticVirtualTextWarn",  { fg = c.ink_orange, italic = true })
hi("DiagnosticVirtualTextInfo",  { fg = c.ink_teal, italic = true })
hi("DiagnosticVirtualTextHint",  { fg = c.ink_green, italic = true })

hi("DiagnosticUnderlineError", { undercurl = true, sp = c.ink_red })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.ink_orange })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.ink_teal })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.ink_green })

-----------------------------------------------------------------------
-- LSP Highlights
-----------------------------------------------------------------------
hi("LspReferenceText",  { bg = c.selection })
hi("LspReferenceRead",  { bg = c.selection })
hi("LspReferenceWrite", { bg = c.selection, bold = true })
hi("LspSignatureActiveParameter", { fg = c.ink_gold, bold = true })
hi("LspCodeLens",       { fg = c.fg_dark, italic = true })
hi("LspInlayHint",      { fg = c.fg_dark, italic = true })

-----------------------------------------------------------------------
-- Treesitter Highlights
-----------------------------------------------------------------------
-- Comments - faded pencil sketches
hi("@comment",               { fg = c.fg_dark, italic = true })
hi("@comment.documentation", { fg = c.fg_dim, italic = true })
hi("@comment.error",         { fg = c.ink_red, bold = true })
hi("@comment.warning",       { fg = c.ink_orange, bold = true })
hi("@comment.todo",          { fg = c.bg, bg = c.ink_gold, bold = true })
hi("@comment.note",          { fg = c.ink_teal, bold = true })

-- Literals - handwritten values
hi("@string",          { fg = c.ink_green })
hi("@string.escape",   { fg = c.ink_orange })
hi("@string.regex",    { fg = c.ink_purple })
hi("@string.special",  { fg = c.ink_purple })
hi("@character",       { fg = c.ink_green })
hi("@character.special", { fg = c.ink_orange })
hi("@number",          { fg = c.ink_gold })
hi("@number.float",    { fg = c.ink_gold })
hi("@boolean",         { fg = c.ink_orange })

-- Identifiers
hi("@variable",          { fg = c.fg })
hi("@variable.builtin",  { fg = c.ink_purple })
hi("@variable.parameter", { fg = c.fg_dim })
hi("@variable.member",   { fg = c.fg })

hi("@constant",          { fg = c.ink_purple })
hi("@constant.builtin",  { fg = c.ink_purple })
hi("@constant.macro",    { fg = c.ink_teal })

hi("@module",            { fg = c.ink_teal })
hi("@label",             { fg = c.ink_sepia })

-- Functions - blue ink
hi("@function",          { fg = c.ink_blue })
hi("@function.builtin",  { fg = c.ink_blue })
hi("@function.call",     { fg = c.ink_blue })
hi("@function.macro",    { fg = c.ink_teal })
hi("@function.method",   { fg = c.ink_blue })
hi("@function.method.call", { fg = c.ink_blue })
hi("@constructor",       { fg = c.ink_sepia })

-- Keywords - brown ink
hi("@keyword",           { fg = c.ink_brown })
hi("@keyword.coroutine", { fg = c.ink_brown })
hi("@keyword.function",  { fg = c.ink_brown })
hi("@keyword.operator",  { fg = c.fg_dim })
hi("@keyword.import",    { fg = c.ink_teal })
hi("@keyword.type",      { fg = c.ink_brown })
hi("@keyword.modifier",  { fg = c.ink_brown })
hi("@keyword.repeat",    { fg = c.ink_brown })
hi("@keyword.return",    { fg = c.ink_brown })
hi("@keyword.exception", { fg = c.ink_red })
hi("@keyword.conditional", { fg = c.ink_brown })

-- Operators / Punctuation
hi("@operator",          { fg = c.fg_dim })
hi("@punctuation.bracket", { fg = c.fg_dim })
hi("@punctuation.delimiter", { fg = c.fg_dim })
hi("@punctuation.special", { fg = c.ink_purple })

-- Types - sepia ink
hi("@type",              { fg = c.ink_sepia })
hi("@type.builtin",      { fg = c.ink_sepia })
hi("@type.definition",   { fg = c.ink_sepia })
hi("@type.qualifier",    { fg = c.ink_brown })

hi("@attribute",         { fg = c.ink_teal })
hi("@attribute.builtin", { fg = c.ink_teal })
hi("@property",          { fg = c.fg })

-- Tags (HTML/JSX)
hi("@tag",               { fg = c.ink_blue })
hi("@tag.builtin",       { fg = c.ink_blue })
hi("@tag.attribute",     { fg = c.ink_brown })
hi("@tag.delimiter",     { fg = c.fg_dim })

-- Markup
hi("@markup.heading",    { fg = c.ink_sepia, bold = true })
hi("@markup.heading.1",  { fg = c.ink_sepia, bold = true })
hi("@markup.heading.2",  { fg = c.ink_sepia, bold = true })
hi("@markup.heading.3",  { fg = c.ink_brown, bold = true })
hi("@markup.heading.4",  { fg = c.ink_brown })
hi("@markup.heading.5",  { fg = c.ink_brown })
hi("@markup.heading.6",  { fg = c.ink_brown })

hi("@markup.strong",     { bold = true })
hi("@markup.italic",     { italic = true })
hi("@markup.strikethrough", { strikethrough = true })
hi("@markup.underline",  { underline = true })

hi("@markup.quote",      { fg = c.fg_dim, italic = true })
hi("@markup.math",       { fg = c.ink_teal })
hi("@markup.link",       { fg = c.ink_teal, underline = true })
hi("@markup.link.label", { fg = c.ink_blue })
hi("@markup.link.url",   { fg = c.ink_teal, underline = true })
hi("@markup.raw",        { fg = c.ink_green })
hi("@markup.raw.block",  { fg = c.ink_green })
hi("@markup.list",       { fg = c.ink_brown })
hi("@markup.list.checked", { fg = c.ink_green })
hi("@markup.list.unchecked", { fg = c.fg_dark })

-- Diff
hi("@diff.plus",         { fg = c.ink_green })
hi("@diff.minus",        { fg = c.ink_red })
hi("@diff.delta",        { fg = c.ink_teal })

-----------------------------------------------------------------------
-- Git Signs
-----------------------------------------------------------------------
hi("GitSignsAdd",          { fg = c.ink_green })
hi("GitSignsChange",       { fg = c.ink_teal })
hi("GitSignsDelete",       { fg = c.ink_red })
hi("GitSignsAddNr",        { fg = c.ink_green })
hi("GitSignsChangeNr",     { fg = c.ink_teal })
hi("GitSignsDeleteNr",     { fg = c.ink_red })
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
hi("TelescopeTitle",       { fg = c.ink_sepia, bold = true })
hi("TelescopePromptNormal", { fg = c.fg, bg = c.bg_alt })
hi("TelescopePromptBorder", { fg = c.border, bg = c.bg_alt })
hi("TelescopePromptTitle", { fg = c.ink_gold, bold = true })
hi("TelescopeResultsNormal", { fg = c.fg, bg = c.bg_float })
hi("TelescopeSelection",   { bg = c.selection })
hi("TelescopeMatching",    { fg = c.ink_gold, bold = true })

-----------------------------------------------------------------------
-- NvimTree / Oil
-----------------------------------------------------------------------
hi("NvimTreeNormal",       { fg = c.fg, bg = c.bg })
hi("NvimTreeRootFolder",   { fg = c.ink_sepia, bold = true })
hi("NvimTreeFolderName",   { fg = c.ink_blue })
hi("NvimTreeFolderIcon",   { fg = c.ink_brown })
hi("NvimTreeOpenedFolderName", { fg = c.ink_blue, bold = true })
hi("NvimTreeEmptyFolderName", { fg = c.fg_dim })
hi("NvimTreeSymlink",      { fg = c.ink_teal })
hi("NvimTreeExecFile",     { fg = c.ink_green, bold = true })
hi("NvimTreeSpecialFile",  { fg = c.ink_purple })
hi("NvimTreeIndentMarker", { fg = c.bg_alt })
hi("NvimTreeGitDirty",     { fg = c.ink_orange })
hi("NvimTreeGitNew",       { fg = c.ink_green })
hi("NvimTreeGitDeleted",   { fg = c.ink_red })

hi("OilDir",               { fg = c.ink_blue, bold = true })
hi("OilFile",              { fg = c.fg })

-----------------------------------------------------------------------
-- Which-Key
-----------------------------------------------------------------------
hi("WhichKey",             { fg = c.ink_sepia })
hi("WhichKeyGroup",        { fg = c.ink_blue })
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
hi("BlinkCmpLabelMatch",   { fg = c.ink_gold, bold = true })
hi("BlinkCmpKind",         { fg = c.fg_dim })

hi("BlinkCmpKindFunction", { fg = c.ink_blue })
hi("BlinkCmpKindMethod",   { fg = c.ink_blue })
hi("BlinkCmpKindVariable", { fg = c.fg })
hi("BlinkCmpKindKeyword",  { fg = c.ink_brown })
hi("BlinkCmpKindText",     { fg = c.fg_dim })
hi("BlinkCmpKindSnippet",  { fg = c.ink_purple })
hi("BlinkCmpKindClass",    { fg = c.ink_sepia })
hi("BlinkCmpKindInterface", { fg = c.ink_sepia })
hi("BlinkCmpKindModule",   { fg = c.ink_teal })
hi("BlinkCmpKindProperty", { fg = c.fg })
hi("BlinkCmpKindUnit",     { fg = c.ink_gold })
hi("BlinkCmpKindValue",    { fg = c.ink_purple })
hi("BlinkCmpKindEnum",     { fg = c.ink_sepia })
hi("BlinkCmpKindColor",    { fg = c.ink_purple })
hi("BlinkCmpKindFile",     { fg = c.fg })
hi("BlinkCmpKindFolder",   { fg = c.ink_blue })
hi("BlinkCmpKindConstant", { fg = c.ink_purple })
hi("BlinkCmpKindField",    { fg = c.fg })
hi("BlinkCmpKindStruct",   { fg = c.ink_sepia })

-----------------------------------------------------------------------
-- Harpoon
-----------------------------------------------------------------------
hi("HarpoonActive",        { fg = c.ink_gold, bold = true })
hi("HarpoonInactive",      { fg = c.fg_dark })

-----------------------------------------------------------------------
-- Todo Comments
-----------------------------------------------------------------------
hi("TodoBgFIX",            { fg = c.bg, bg = c.ink_red, bold = true })
hi("TodoBgTODO",           { fg = c.bg, bg = c.ink_gold, bold = true })
hi("TodoBgHACK",           { fg = c.bg, bg = c.ink_orange, bold = true })
hi("TodoBgWARN",           { fg = c.bg, bg = c.ink_orange, bold = true })
hi("TodoBgNOTE",           { fg = c.bg, bg = c.ink_teal, bold = true })
hi("TodoBgPERF",           { fg = c.bg, bg = c.ink_purple, bold = true })

hi("TodoFgFIX",            { fg = c.ink_red })
hi("TodoFgTODO",           { fg = c.ink_gold })
hi("TodoFgHACK",           { fg = c.ink_orange })
hi("TodoFgWARN",           { fg = c.ink_orange })
hi("TodoFgNOTE",           { fg = c.ink_teal })
hi("TodoFgPERF",           { fg = c.ink_purple })

-----------------------------------------------------------------------
-- Lazy.nvim
-----------------------------------------------------------------------
hi("LazyButton",           { fg = c.fg, bg = c.bg_alt })
hi("LazyButtonActive",     { fg = c.bg, bg = c.ink_brown, bold = true })
hi("LazyH1",               { fg = c.bg, bg = c.ink_sepia, bold = true })
hi("LazyH2",               { fg = c.ink_sepia, bold = true })
hi("LazySpecial",          { fg = c.ink_teal })
hi("LazyCommit",           { fg = c.ink_green })
hi("LazyReasonPlugin",     { fg = c.ink_blue })
hi("LazyReasonFt",         { fg = c.ink_brown })
hi("LazyReasonCmd",        { fg = c.ink_teal })
hi("LazyReasonEvent",      { fg = c.ink_purple })
hi("LazyReasonStart",      { fg = c.ink_gold })

-----------------------------------------------------------------------
-- Barbecue (breadcrumbs)
-----------------------------------------------------------------------
hi("BarbecueDirname",      { fg = c.fg_dark })
hi("BarbecueBasename",     { fg = c.fg_dim, bold = true })
hi("BarbecueSeparator",    { fg = c.fg_dark })
hi("BarbecueContext",      { fg = c.fg_dim })
