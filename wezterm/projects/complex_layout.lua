-- Complex project layout with multiple panes
return {
	name = "complex-dev",
	root_dir = "~/projects/complex-app", -- Change this to your actual project path
	tabs = {
		{
			name = "services",
			dir = "services",
			panes = {
				{ 
					command = "docker-compose up api",
					focus = true
				},
				{ 
					command = "docker-compose up database",
					split = "right"
				},
				{ 
					command = "docker-compose logs -f",
					split = "bottom"
				}
			}
		},
		{
			name = "frontend",
			dir = "frontend",
			panes = {
				{ command = "npm run dev" },
				{ 
					command = "npm run test:watch",
					split = "right"
				}
			}
		},
		{
			name = "monitoring",
			panes = {
				{ command = "htop" },
				{ 
					command = "watch -n 1 'docker ps'",
					split = "right"
				},
				{
					command = "tail -f /var/log/system.log",
					split = "bottom"
				}
			}
		},
		{
			name = "tools",
			panes = {
				{ command = "nvim ." }
			}
		}
	}
}