# WezTerm Projectifier - Project Configurations

This directory contains Lua-based project configurations for the WezTerm Projectifier system. Each `.lua` file defines a project layout with tabs, panes, and commands.

## Usage

Press **Ctrl+t** in WezTerm to open the project picker and select a project to build.

## Project Configuration Format

```lua
-- my_project.lua
return {
  name = "my-project-name",           -- Workspace name (required)
  root_dir = "~/path/to/project",     -- Project root directory (default: home)
  tabs = {                            -- Array of tab configurations
    {
      name = "tab-name",              -- Tab title
      dir = "relative/path",          -- Directory relative to root_dir (optional)
      panes = {                       -- Array of pane configurations
        { 
          command = "npm run dev",    -- Command to run in pane (optional)
          focus = true,               -- Set initial focus to this pane (optional)
          split = "right"             -- Split direction: "right" or "bottom" (optional)
        }
      }
    }
  }
}
```

## Configuration Options

### Root Level
- `name` (required): Workspace name
- `root_dir` (optional): Project root directory, defaults to `~`
- `tabs` (required): Array of tab configurations

### Tab Level
- `name` (optional): Tab title, defaults to "Tab N"
- `dir` (optional): Directory relative to `root_dir`, defaults to `root_dir`
- `panes` (optional): Array of pane configurations, defaults to single empty pane
- `command` (optional): Single command shorthand (creates one pane with this command)

### Pane Level
- `command` (optional): Command to execute in the pane
- `focus` (optional): Set to `true` to focus this pane initially
- `split` (optional): Split direction - "right" (horizontal) or "bottom" (vertical)
- `dir` (optional): Directory relative to tab's base directory

## Split Behavior

- First pane in a tab uses the existing pane
- Subsequent panes split from the current active pane
- `split = "right"` creates horizontal split (pane appears to the right)
- `split = "bottom"` creates vertical split (pane appears below)
- Default split is "right" if not specified

## Examples

### Simple Project
```lua
return {
  name = "blog",
  root_dir = "~/projects/my-blog",
  tabs = {
    { name = "server", panes = {{ command = "hugo server" }} },
    { name = "editor", panes = {{ command = "nvim ." }} }
  }
}
```

### Complex Layout
```lua
return {
  name = "fullstack-app",
  root_dir = "~/projects/app",
  tabs = {
    {
      name = "backend",
      dir = "api",
      panes = {
        { command = "npm run dev", focus = true },
        { command = "npm run test:watch", split = "right" },
        { command = "tail -f logs/app.log", split = "bottom" }
      }
    },
    {
      name = "frontend", 
      dir = "web",
      panes = {
        { command = "npm start" }
      }
    }
  }
}
```

## Tips

1. **Test your configs**: Create simple configs first and test them before adding complexity
2. **Use relative paths**: Use `dir` relative to `root_dir` for portability
3. **Focus management**: Use `focus = true` on the pane you want to start in
4. **Command chaining**: Use `&&` to chain commands: `"cd src && npm test"`
5. **Background processes**: Some commands may need `&` to run in background
6. **Error handling**: If a command fails, the pane will show the error

## File Naming

- Files must end with `.lua`
- Filename (without extension) is used as fallback project name
- Use descriptive names like `my_blog.lua` or `work_project.lua`

## Troubleshooting

- Check WezTerm logs if projects don't load: `tail -f ~/.config/wezterm/wezterm.log`
- Ensure paths exist and are accessible
- Commands are executed with `bash -c`, so shell features work
- Test commands manually in terminal before adding to config