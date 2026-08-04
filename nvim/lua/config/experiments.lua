-- Optional scratchpad for trying Neovim changes without touching stable modules.
--
-- Load explicitly with :Experiments, or start Neovim with:
--   NVIM_EXPERIMENTS=1 nvim
--
-- Keep experimental plugin declarations in this file only while evaluating
-- them. Move proven configuration into the regular modules, then remove it.
local M = {}

M.loaded = false

function M.setup()
  if M.loaded then
    return
  end

  M.loaded = true

  -- Add temporary experiments below. Example:
  -- vim.keymap.set('n', '<leader>xe', function()
  --   vim.notify('Experiment enabled')
  -- end, { desc = 'Experimental action' })
end

return M
