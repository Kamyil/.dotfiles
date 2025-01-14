-- For smart comments on <leader>/
return {
  'numToStr/Comment.nvim',
  enabled = true,
  lazy = false,
  opts = {
    -- add any options here
  },
  -- Define a custom function to handle Smarty comments
  pre_hook = function(context)
    -- Determine the file type, here we assume .tpl files are Smarty templates
    local filetype = vim.bo.filetype

    if filetype == 'smarty' then
      -- Set the commentstring for Smarty templates
      vim.bo.commentstring = '{* %s *}'
    end
  end,
}
