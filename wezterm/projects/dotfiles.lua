-- Dotfiles management project
return {
	name = "dotfiles",
	root_dir = "~/.dotfiles",
	tabs = {
		{
			name = "wezterm",
			dir = "wezterm",
			panes = {
				{ 
					command = "nvim wezterm.lua",
					focus = true
				},
				{ 
					command = "tail -f ~/.config/wezterm/wezterm.log",
					split = "right"
				}
			}
		},
		{
			name = "config",
			panes = {
				{ command = "ls -la" }
			}
		},
		{
			name = "git",
			panes = {
				{ command = "git status && echo 'Ready for git operations...'" }
			}
		}
	}
}
