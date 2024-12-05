-- For better markdown annotations
return {
  'danymat/neogen',

  enabled = true,
  dependencies = {},
  cmd = 'Neogen',
  opts = {
    snippet_engine = 'luasnip',
    languages = {
      lua = { template = { annotation_convention = 'ldoc' } },
      typescript = { template = { annotation_convention = 'tsdoc' } },
      typescriptreact = { template = { annotation_convention = 'tsdoc' } },
    },
  },
}
