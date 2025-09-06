-- Simple project configuration example
return {
	name = "simple-website",
	root_dir = "~/projects/simple-site", -- Change this to your actual project path
	tabs = {
		{
			name = "dev-server",
			panes = {
				{ command = "python -m http.server 8000" }
			}
		},
		{
			name = "editor",
			panes = {
				{ command = "nvim index.html" }
			}
		},
		{
			name = "git",
			panes = {
				{ command = "git status" }
			}
		}
	}
}