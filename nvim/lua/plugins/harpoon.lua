return {
  {
    'ThePrimeagen/harpoon',
    enabled = true,
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  {
    'kiennt63/harpoon-files.nvim',
    enabled = true,
    opts = {
      max_length = 30,
      icon = '',
      show_icon = true,
      show_index = true,
      show_filename = true,
      separator_left = ' ',
      separator_right = ' ',
    },
  }, -- for showing the current harpoon indexes
}
