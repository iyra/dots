return {
  'neovim/nvim-lspconfig',
  {'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended
  lazy = false}, -- This plugin is already lazy
  {
    'dgagn/diagflow.nvim',
    -- event = 'LspAttach', This is what I use personnally and it works great
    opts = {
        scope = 'line',
        max_height = 15
    }
  }
}
