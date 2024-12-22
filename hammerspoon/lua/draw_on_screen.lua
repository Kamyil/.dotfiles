local M = {}

local drawingLayer = {} -- Table to hold all drawings
local isDrawing = false -- Flag to track drawing state
local lastMousePosition = nil -- Track the last mouse position
local mouseEventTap = nil -- Event tap for tracking mouse movements

-- Function to start drawing
M.startDrawing = function()
	-- If already drawing, do nothing
	if isDrawing then
		return
	end

	isDrawing = true
	hs.alert.show("Drawing started")

	-- Clear any previous drawings
	for _, drawing in ipairs(drawingLayer) do
		drawing:delete()
	end
	drawingLayer = {}

	-- Get initial mouse position
	lastMousePosition = hs.mouse.absolutePosition()

	-- Start tracking mouse movement
	mouseEventTap = hs.eventtap.new({ hs.eventtap.event.types.mouseMoved }, function(event)
		local currentPosition = event:location()
		if lastMousePosition then
			-- Draw a line between the last position and the current position
			local line = hs.drawing.line(
				{ x = lastMousePosition.x, y = lastMousePosition.y },
				{ x = currentPosition.x, y = currentPosition.y }
			)
			line:setStrokeColor({ ["red"] = 1, ["green"] = 0, ["blue"] = 0, ["alpha"] = 1 })
			line:setStrokeWidth(2)
			line:show()
			table.insert(drawingLayer, line)
		end
		lastMousePosition = currentPosition
		return false
	end)
	mouseEventTap:start()
end

-- Function to stop drawing
M.stopDrawing = function()
	if not isDrawing then
		return
	end

	isDrawing = false
	hs.alert.show("Drawing stopped")

	-- Stop tracking mouse movement
	if mouseEventTap then
		mouseEventTap:stop()
		mouseEventTap = nil
	end

	-- Clear all drawings from the screen
	for _, drawing in ipairs(drawingLayer) do
		drawing:delete()
	end
	drawingLayer = {}
end

return M
