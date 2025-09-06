-- Example fullstack project configuration
return {
	name = "fullstack-demo",
	root_dir = "~/projects/my-fullstack-app", -- Change this to your actual project path
	tabs = {
		{
			name = "backend",
			dir = "backend", -- relative to root_dir
			panes = {
				{ 
					command = "npm run dev", 
					focus = true  -- This pane gets initial focus
				},
				{ 
					command = "tail -f logs/app.log", 
					split = "bottom"  -- Split below the first pane
				}
			}
		},
		{
			name = "frontend",
			dir = "frontend",
			panes = {
				{ command = "npm start" }
			}
		},
		{
			name = "database",
			dir = ".", -- Use root directory
			panes = {
				{ command = "docker-compose up -d && docker logs -f app_db" }
			}
		},
		{
			name = "editor",
			dir = ".",
			panes = {
				{ command = "nvim ." }
			}
		}
	}
}