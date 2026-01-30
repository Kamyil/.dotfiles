local settings = require("fonts")
local icons = {
	sf_symbols = {
		plus = "􀅼",
		loading = "􀖇",
		apple = "􀣺",
		gear = "􀍟",
		cpu = "􀫥",
		clipboard = "􀉄",

		switch = {
			on = "􁏮",
			off = "􁏯",
		},
		volume = {
			_100 = "􀊩",
			_66 = "􀊧",
			_33 = "􀊥",
			_10 = "􀊡",
			_0 = "􀊣",
		},
		battery = {
			_100 = "􀛨",
			_75 = "􀺸",
			_50 = "􀺶",
			_25 = "􀛩",
			_0 = "􀛪",
			charging = "􀢋",
		},
		wifi = {
			upload = "􀄨",
			download = "􀄩",
			connected = "􀙇",
			disconnected = "􀙈",
			router = "􁓤",
		},
		media = {
			back = "􀊑",
			forward = "􀊓",
			play_pause = "􀊇",
		},
	},

	-- Alternative NerdFont icons (matching waybar icons)
	nerdfont = {
		plus = "+",
		loading = "󰔟",
		apple = "􀣺",
		gear = "󰢻",
		cpu = "󰍛",
		memory = "󰘚",
		clipboard = "󰅌",

		switch = {
			on = "󱨥",
			off = "󱨦",
		},
		volume = {
			_100 = "",
			_66 = "",
			_33 = "",
			_10 = "",
			_0 = "",
		},
		battery = {
			_100 = "󰁹",
			_75 = "󰂂",
			_50 = "󰁿",
			_25 = "󰁽",
			_0 = "󰁺",
			charging = "󰂄",
		},
		wifi = {
			upload = "󰁞",
			download = "󰁆",
			connected = "󰤨",
			disconnected = "󰤮",
			router = "󰣺",
		},
		media = {
			back = "󰒮",
			forward = "󰒭",
			play_pause = "󰐎",
		},
		workspace = {
			default = "",
			active = "󱓻",
		},
	},
}

return icons.nerdfont