-- Rex configuration, ported from herdr/config.toml.
-- Docs: https://www.superlogical.com/rex/docs/customize/keyboard-shortcuts
-- Apply changes with `rex config reload`, validate with `rex config check`.
--
-- herdr's `prefix+x` is written here as the key sequence "alt+space>x".
-- Keys are written unshifted: `prefix+?` becomes "alt+space>shift+/".

local terminal = "com.superlogical.terminal"
local shell = "com.superlogical.terminal.shell"
local P = "alt+space>"

local function bind_all(keys, action, args)
  for _, key in ipairs(keys) do
    rex.bind(key, action, args)
  end
end

local function foreground(ctx)
  local p = rex.block.call(terminal, "process", { block_id = ctx.block_id })
  return p and p.foreground
end

-- Same match as herdr-navigate.sh: ^g?(view|l?n?vim?x?)(diff)?$
local function is_vim(name)
  -- Fresh locals on purpose: `name = (name:gsub(...))` panics Rex's Lua runtime.
  local base = name:lower():gsub("^g", "")
  base = base:gsub("diff$", "")
  return base == "view" or base:match("^l?n?vim?x?$") ~= nil
end

-- Custom actions ------------------------------------------------------------

local vim_keys = { left = "h", down = "j", up = "k", right = "l" }

rex.action{
  name = "navigate",
  title = "Navigate Pane (Vim-aware)",
  description = "Send ctrl+hjkl to Vim when it is in the foreground, otherwise focus the pane in that direction.",
  args = { direction = "string" },
  run = function(ctx, args)
    local fg = foreground(ctx)
    if fg and fg.name and is_vim(fg.name) then
      rex.client.queue("pane.send_key", { key = "ctrl+" .. vim_keys[args.direction] })
    else
      rex.client.queue("pane.focus", { direction = args.direction })
    end
  end,
}

rex.action{
  name = "split_run",
  title = "Run Command in Split",
  args = { command = "array" },
  run = function(ctx, args)
    local fg = foreground(ctx)
    local _, err = rex.session.new_split{
      anchor_id = ctx.block_id,
      direction = "horizontal",
      side = "after",
      focus = true,
      layout = rex.layout.block{
        flavor = shell,
        options = { command = args.command, cwd = fg and fg.cwd },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}

rex.action{
  name = "new_floating_pane",
  title = "New Floating Pane",
  run = function(ctx, args)
    local fg = foreground(ctx)
    local _, err = rex.session.new_layer{
      bounds = { 0.15, 0.15, 0.7, 0.7 },
      focus = true,
      layout = rex.layout.block{
        flavor = shell,
        options = { cwd = fg and fg.cwd },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}

rex.action{
  name = "edit_scrollback",
  title = "Edit Scrollback in Neovim",
  run = function(ctx, args)
    local r, err = rex.block.call(terminal, "format", { block_id = ctx.block_id, format = "text" })
    if r == nil then error(err, 0) end
    local path = os.tmpname()
    local f = assert(io.open(path, "w"))
    f:write(r.content or "")
    f:close()
    local _, werr = rex.session.new_window{
      layout = rex.layout.block{
        flavor = shell,
        options = { command = { "nvim", "+", path } },
      },
    }
    if werr ~= nil then error(werr, 0) end
  end,
}

rex.action{
  name = "session_goto",
  title = "Go to Session by Number",
  args = { index = "integer" },
  run = function(ctx, args)
    local r, err = rex.call("session.list")
    if r == nil then error(err, 0) end
    local s = (r.sessions or {})[args.index]
    if s then rex.client.queue("session.select", { session_id = s.session_id }) end
  end,
}

-- General -------------------------------------------------------------------

rex.bind(P .. "shift+/", "client.palette.toggle") -- help
rex.bind(P .. "g", "client.palette.toggle") -- goto
bind_all({ P .. "shift+r", P .. "alt+s" }, "client.config.reload")
rex.bind(P .. "s", "client.settings")

-- Sessions (herdr workspaces) -------------------------------------------------

rex.bind(P .. "w", "session.switch")
bind_all({ P .. "shift+n", "ctrl+shift+n" }, "session.new")
rex.bind(P .. "shift+w", "session.rename")
bind_all({ P .. "shift+d", "ctrl+shift+x" }, "session.close")
bind_all({ P .. "shift+left", "ctrl+shift+k" }, "session.previous")
bind_all({ P .. "shift+right", "ctrl+shift+j" }, "session.next")
for i = 1, 9 do
  bind_all({ P .. "shift+" .. i, "ctrl+alt+" .. i, "ctrl+shift+" .. i, "alt+shift+" .. i },
    "session_goto", { index = i })
end

-- Tabs ----------------------------------------------------------------------

bind_all({ P .. "c", "ctrl+n" }, "client.tab.new")
bind_all({ P .. "shift+t", "ctrl+r" }, "client.tab.rename")
bind_all({ P .. "p", "ctrl+shift+h" }, "client.tab.previous")
bind_all({ P .. "n", "ctrl+shift+l" }, "client.tab.next")
bind_all({ P .. "shift+x", "ctrl+w" }, "client.tab.close")
for i = 1, 9 do
  bind_all({ P .. i, "ctrl+" .. i }, "client.tab.goto", { index = i })
end

-- Panes ---------------------------------------------------------------------

for dir, key in pairs(vim_keys) do
  bind_all({ P .. key, "ctrl+alt+" .. key }, "pane.focus." .. dir)
  rex.bind(P .. "shift+" .. key, "pane.move." .. dir) -- herdr swap_pane
  rex.bind("alt+shift+" .. key, "pane.resize", { direction = dir })
  rex.bind("ctrl+" .. key, "navigate", { direction = dir })
end

rex.bind(P .. "tab", "pane.focus_next")
rex.bind(P .. "shift+tab", "pane.focus_previous")

bind_all({ P .. "v", "ctrl+alt+d", "ctrl+/" }, "pane.split.right")
bind_all({ P .. "-", "ctrl+alt+shift+d", "ctrl+shift+/" }, "pane.split.down")
rex.bind("ctrl+shift+f", "new_floating_pane")
bind_all({ P .. "x", "ctrl+x" }, "pane.close")
bind_all({ P .. "z", "ctrl+alt+z", "ctrl+z" }, "pane.zoom")
rex.bind("ctrl+f", "client.find.open") -- closest thing to herdr copy_mode
rex.bind(P .. "e", "edit_scrollback")
bind_all({ P .. "b", "ctrl+shift+e" }, "client.sidebar.toggle")

rex.bind(P .. "alt+g", "split_run", { command = { "lazygit" } })
rex.bind(P .. "alt+e", "split_run", { command = { "nvim" } })

-- Resize mode ---------------------------------------------------------------

rex.mode("resize", { exclusive = true })
rex.bind(P .. "r", "client.mode.enter", { name = "resize" })
for dir, key in pairs(vim_keys) do
  rex.bind("resize/" .. key, "pane.resize", { direction = dir })
  rex.bind("resize/" .. dir, "pane.resize", { direction = dir })
  rex.bind("resize/shift+" .. key, "pane.resize", { direction = dir, amount = 15 })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/q", "client.mode.exit")

-- Not ported (no Rex equivalent yet):
--   detach (prefix+q), last_pane (prefix+`), rename_pane (prefix+shift+p),
--   worktrees (prefix+shift+g / shift+o / alt+d),
--   agent navigation (prefix+alt+p / alt+n / alt+1..9),
--   herdr-agent-quota plugin actions (prefix+shift+a / shift+q).
