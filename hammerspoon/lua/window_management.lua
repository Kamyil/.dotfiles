local M = {}

M.snapLeft = function()
	hs.window.focusedWindow():moveToUnit(hs.layout.left50)
end

M.snapRight = function()
	hs.window.focusedWindow():moveToUnit(hs.layout.right50)
end

M.snapTop = function()
	hs.window.focusedWindow():moveToUnit({ 0, 0, 1, 0.5 })
end
M.snapBottom = function()
	hs.window.focusedWindow():moveToUnit({ 0, 0.5, 1, 0.5 })
end

M.almostMaximize = function()
	hs.window.focusedWindow():moveToUnit({ 0.05, 0.05, 0.9, 0.9 })
end

M.reasonableSize = function()
	hs.window.focusedWindow():moveToUnit({ 0.25, 0.25, 0.5, 0.5 })
end

M.maximize = function()
	hs.window.focusedWindow():maximize(0) -- Maximize without fullscreen
end

M.smaller = function()
	local currentSize = hs.window.focusedWindow():size()

	hs.window.focusedWindow():setSize({
		w = currentSize.w - 50,
		h = currentSize.h - 50,
	})
end

M.bigger = function()
	local currentSize = hs.window.focusedWindow():size()

	hs.window.focusedWindow():setSize({
		w = currentSize.w + 50,
		h = currentSize.h + 50,
	})
end

return M
