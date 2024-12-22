local M = {}

M.doReload = false

M.setupLiveConfigReload = function(files)
	M.doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			M.doReload = true
		end
	end
	if M.doReload then
		hs.reload()
	end

	local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.config/hammerspoon", M.setupLiveConfigReload):start()
	hs.alert.show("Hammerspoon config reloaded")
end

return M
