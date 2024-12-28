-- Thanks to https://mwop.net/blog/2024-10-21-wezterm-keybindings.html <3

local utils = {}

utils.merge = function(base, overrides)
	local ret = base or {}
	local second = overrides or {}
	for _, v in pairs(second) do
		table.insert(ret, v)
	end
	return ret
end

---Merges two tables
---@param t1 table
---@return table t1 modified t1 table
utils.deep_merge = function(t1, t2)
	local table_to_merge = { t2 }

	for i = 1, #table_to_merge do
		local t2 = table_to_merge[i]
		for k, v in pairs(t2) do
			if type(v) == "table" then
				if type(t1[k] or false) == "table" then
					utils.deep_merge(t1, t2)(t1[k] or {}, t2[k] or {})
				else
					t1[k] = v
				end
			else
				t1[k] = v
			end
		end
	end

	return t1
end

return utils
