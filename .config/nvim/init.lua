-- general settings
vim.opt.hidden = true -- for buffer switching

-- backups
vim.opt.backupdir = '/home/lyra/.local/share/nvim/backup//'
vim.opt.backup = true

-- misc options
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.autoindent = true
vim.opt.smartindent = true -- we have treesitter

-- Add timestamp as extension for backup files
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('timestamp_backupext', { clear = true }),
  desc = 'Add timestamp to backup extension',
  pattern = '*',
  callback = function()
    vim.opt.backupext = '-' .. vim.fn.strftime('%Y%m%d%H%M')
  end,
})

-- color theme
require("config.lazy")
vim.cmd 'set background=dark'
vim.cmd 'colorscheme moonfly'

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- set line limit
vim.opt.colorcolumn = "79"

-- indent blank line
require("ibl").setup()

-- misc loads
require('lualine').setup({
        options = {
                theme = "moonfly"
        },
	sections = {
	    lualine_a = {'mode'},
	    lualine_b = {'branch', 'diff', 'diagnostics'},
	    lualine_c = {{'filename', path = 1}},
	    lualine_x = {'encoding', 'fileformat', 'filetype'},
	    lualine_y = {'progress'},
	    lualine_z = {'location'}
  	}
})
require("telescope").load_extension "file_browser"

-- completion and LSP
local cmp = require('cmp')
cmp.setup({
        mapping = cmp.mapping.preset.insert({
              ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
              else
                fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
              end
            end, { "i", "s" }),

            ["<S-Tab>"] = cmp.mapping(function()
              if cmp.visible() then
                cmp.select_prev_item()
              elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
              end
            end, { "i", "s" }),
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        snippet = {
        -- REQUIRED - you must specify a snippet engine
                expand = function(args)
                        vim.snippet.expand(args.body)
                end,
        },
        sources = {
    { name = 'path' },                              -- file paths
    { name = 'nvim_lsp', keyword_length = 2},      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'buffer', keyword_length = 2 },        -- source current buffer
    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip
    { name = "crates" }
        }
})

vim.lsp.enable('pyright')

-- LSP window borders
local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = _border
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = _border
  }
)

vim.diagnostic.config{
  float={border=_border}
}

require('crates').setup({
        lsp = {
                enabled = true,
                actions = true,
                completion = true,
                hover = true
        },
        completion = {
                cmp = {
                        enabled = true,
                },
        },
})

-- https://github.com/nvim-telescope/telescope.nvim/issues/592
my_fd = function(opts)
  opts = opts or {}
  opts.cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  require'telescope.builtin'.find_files(opts)
end

-- keymap
-- telescope general
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', ":Telescope find_files no_ignore=true hidden=true<CR>")
vim.keymap.set('n', '<leader>fa', my_fd)
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>bf', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fb', ":Telescope file_browser no_ignore=true hidden=true path=%:p:h select_buffer=true<CR>")
vim.keymap.set("n", "<leader>gr", function()
			require("telescope.builtin").lsp_references({ jump_type = "never" })
		end)
vim.keymap.set("n", "<leader>gde", vim.lsp.buf.declaration)
vim.keymap.set("n", "<leader>gdf", "<cmd>Telescope lsp_definitions<CR>")
vim.keymap.set("n", "<leader>gi", "<cmd>Telescope lsp_implementations<CR>")
vim.keymap.set("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>")
vim.keymap.set("n", "<leader>gf", function()
			require("telescope.builtin").lsp_definitions({ jump_type = "never" })
		end)
vim.keymap.set({ "n", "v" }, "<leader>gca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>grn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>geb", "<cmd>Telescope diagnostics bufnr=0<CR>")
vim.keymap.set("n", "<leader>gea", "<cmd>Telescope diagnostics<CR>")
vim.keymap.set("n", "<leader>gE", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>gl", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>gh", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>g\\", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>gq", ":LspRestart<CR>")


vim.diagnostic.config({
  virtual_text = false
})

require("mason").setup()
local dap = require("dap")
dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    -- CHANGE THIS to your path!
    command = '/usr/bin/codelldb',
    args = {"--port", "${port}"},

    -- On windows you may have to uncomment this:
    -- detached = false,
  }
}
