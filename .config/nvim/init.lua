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
vim.cmd.colorscheme "catppuccin"

-- tree
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- misc loads
require("neo-tree").setup({
	filesystem = {
		follow_current_file = {
			enabled = true,
			leave_dirs_open = true,
		}
	},
        event_handlers = { 
         { -- disable line numbering in neo-tree
             event = "vim_buffer_enter", 
             handler = function() 
                 if vim.bo.filetype == "neo-tree" then 
                     vim.cmd("setlocal nonumber") 
                 end 
             end, 
         },
        }
})
require('lualine').setup({
        extensions = {'neo-tree'}, 
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
              elseif has_words_before() then
                cmp.complete()
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
                        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                end,
        },
        sources = {
    { name = 'path' },                              -- file paths
    { name = 'nvim_lsp', keyword_length = 2},      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
    { name = 'buffer', keyword_length = 2 },        -- source current buffer
    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip
    { name = "crates" }
        }
})
require('lspconfig').pyright.setup{}
require('lspconfig').emmet_language_server.setup({})
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

-- start neo-tree on startup
vim.api.nvim_create_autocmd("VimEnter", {
      command = "set nornu nonu | Neotree toggle",
    })
vim.api.nvim_create_autocmd("BufEnter", {
command = "set rnu nu",
    })

-- keymap
-- file browser
vim.keymap.set("n", "<space>fr", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")

-- telescope general
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

vim.diagnostic.config({
  virtual_text = false
})

-- Show line diagnostics automatically in hover window
vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
