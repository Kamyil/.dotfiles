-- [[ Hammerspoon ]]
hs = hs

local window_management = require("./lua/window_management")
-- local draw_on_screen = require("./lua/draw_on_screen")
-- INFO: Toggle it when needing to do an Resource Override [unfortunetly it's unstable on Zen :( ]
-- hs.hotkey.bind({ "cmd" }, "1", function()
-- end)

local hs_prefix_key = { "cmd", "shift" }

-- hs.window.setShadows(true)

local function hideOtherWindowsBesideActiveOne()
	hs.eventtap.keyStroke({ "cmd", "alt" }, "h")
end

-- hs.hotkey.bind(hs_prefix_key, "D", draw_on_screen.startDrawing)
-- hs.hotkey.bind(hs_prefix_key, "S", draw_on_screen.stopDrawing)

-- [[
-- -- Focus or launch apps
-- ]]
--
-- hs.hotkey.bind({ "cmd" }, "`", function()
-- 	hs.application.launchOrFocus("Brave Browser")
-- end)

-- hs.hotkey.bind({ "cmd" }, "Space", function()
-- 	-- local cmd = [[
-- 	--    open -n -a WezTerm --args \
-- 	--      --config-file ~/.config/wezterm/launchtty.lua
-- 	--  ]]
-- 	local cmd = [[
-- 		ghostty -e ~/.config/launchtty.lua
-- 	]]
-- 	local ok, _, code = hs.execute(cmd)
-- 	if not ok then
-- 		hs.alert.show("Failed to launch WezTerm: " .. code)
-- 	end
-- end)

hs.hotkey.bind(hs_prefix_key, "b", function()
	hs.caffeinate.lockScreen()
end)

hs.hotkey.bind({ "cmd" }, "1", function()
	-- hs.application.hide("Ghostty")
	-- hideOtherWindowsBesideActiveOne()

	hs.application.launchOrFocus("Vivaldi")
	-- hs.application.launchOrFocus("Zen Browser")

	-- INFO: Toggle it when needing to do an Resource Override [unfortunetly it's unstable on Zen (Firefox) :c ]
	-- hs.application.launchOrFocus("Brave Browser")

	-- INFO: toggle it when need to debug Safari on iOS (iPhone/iPad)
	-- hs.application.launchOrFocus("Safari")
	-- hs.application.launchOrFocus("Simulator")

	-- Hide other windows
end)

hs.hotkey.bind({ "cmd" }, "2", function()
	-- hs.application.launchOrFocus("WezTerm")
	hs.application.launchOrFocus("Ghostty")
	-- hideOtherWindowsBesideActiveOne()
end)

hs.hotkey.bind({ "cmd" }, "3", function()
	-- hs.window:minimize()
	hs.application.launchOrFocus("Slack")

	-- hideOtherWindowsBesideActiveOne()
end)

hs.hotkey.bind({ "cmd" }, "4", function()
	-- hs.window:minimize()
	hs.application.launchOrFocus("Spotify")
	-- hideOtherWindowsBesideActiveOne()
end)

hs.hotkey.bind({ "cmd" }, "5", function()
	hs.application.launchOrFocus("Messenger")
end)

-- TODO: Fill 6 with something useful
-- TODO: Fill 7 with something useful
--
hs.hotkey.bind({ "cmd" }, "8", function()
	hs.application.launchOrFocus("DBeaver")
end)

hs.hotkey.bind({ "cmd" }, "9", function()
	hs.application.launchOrFocus("KeePassX")
	-- hideOtherWindowsBesideActiveOne()
end)

hs.hotkey.bind({ "cmd" }, "0", function()
	hs.application.launchOrFocus("ChatGPT")
	-- hideOtherWindowsBesideActiveOne()
end)

hs.hotkey.bind(hs_prefix_key, ",", window_management.moveToLeftDisplay)
hs.hotkey.bind(hs_prefix_key, ".", window_management.moveToRightDisplay)

-- [[
-- -- Window Management
-- ]]
hs.window.animationDuration = 0 -- Make it fast af boiii hs.hotkey.bind(hs_prefix_key, "H", window_management.snapLeft)
hs.hotkey.bind(hs_prefix_key, "J", window_management.snapBottom)
hs.hotkey.bind(hs_prefix_key, "K", window_management.snapTop)
hs.hotkey.bind(hs_prefix_key, "L", window_management.snapRight)

hs.hotkey.bind(hs_prefix_key, "A", window_management.almostMaximize)
hs.hotkey.bind(hs_prefix_key, "R", window_management.reasonableSize)
hs.hotkey.bind(hs_prefix_key, "C", window_management.center)
hs.hotkey.bind(hs_prefix_key, "F", window_management.maximize) -- "F" like Fullscreen
hs.hotkey.bind(hs_prefix_key, "M", window_management.maximize) -- "M" like Maximize

hs.hotkey.bind(hs_prefix_key, "-", window_management.smaller)
hs.hotkey.bind(hs_prefix_key, "=", window_management.bigger)

-- [[
-- -- Hammerspoon utils
-- ]]
hs.hotkey.bind({ "cmd", "alt" }, "R", function()
	hs.reload()
end)
hs.alert.show("Hammerspoon config reloaded")
--
