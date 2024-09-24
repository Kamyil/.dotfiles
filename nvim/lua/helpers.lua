-- File containing common utility helper functions
local M = {}

-- Helper to get the project root
M.get_project_root = function()
  return vim.fn.getcwd() -- you can modify this to use a more complex project root detection method if needed
end

-- Helper function allowing to run a callback while making sure it's loaded by lazy.nvim
M.on_lazy_plugin_loaded = function(plugin_name, callback)
  -- Create an autocommand for the VeryLazy event to ensure all lazy plugins are loaded
  vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    callback = function()
      -- Safely require the plugin once the VeryLazy event has fired
      local ok, plugin = pcall(require, plugin_name)
      if ok then
        callback(plugin)
      else
        vim.notify("Plugin '" .. plugin_name .. "' not found", vim.log.levels.WARN)
      end
    end,
  })
end

return M
