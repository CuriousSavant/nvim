local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.opt.termguicolors = true


require("lazy").setup({
	{ "neovim/nvim-lspconfig" },
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "L3MON4D3/LuaSnip" },
	{ "saadparwaiz1/cmp_luasnip" },

	{ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },

	{ "tailwindlabs/tailwindcss-intellisense" },

	{ "nvim-telescope/telescope.nvim" },
	{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
	{ "nvim-lualine/lualine.nvim" },
	{ "nvim-tree/nvim-tree.lua" },
	{ "onsails/lspkind-nvim" },
	{ "windwp/nvim-autopairs" },
	{ "windwp/nvim-ts-autotag" },
	{ "jose-elias-alvarez/nvim-lsp-ts-utils" },
	{ "leafgarland/typescript-vim" },
	{ "mattn/emmet-vim" },


	{ "lukas-reineke/lsp-format.nvim" },
	   { "jose-elias-alvarez/null-ls.nvim" },

	{ "nvim-tree/nvim-web-devicons" },

	{ "folke/tokyonight.nvim", lazy = false, priority = 1000 },
	{ "scottmckendry/cyberdream.nvim", lazy = false, priority = 1000 },



	{ "MunifTanjim/nui.nvim" },
	{ "VonHeikemen/fine-cmdline.nvim",
    	config = function()
        	require('fine-cmdline').setup({
            	cmdline = {
                	enable_keymaps = true,
                	smart_history = true,
                	prompt = ': '
            },
            popup = {
                position = {
                    row = "10%",
                    col = "50%",
                },
                size = {
                    width = "60%"
                },
                border = {
                    style = "rounded",
                },
                win_options = {
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                },
            }
        })
    end
}

})

local cmp = require('cmp')
local lspkind = require('lspkind')
local luasnip = require('luasnip')

local cmp_kinds = {
	Text = "  ",
	Method = "  ",
	Function = "  ",
	Constructor = "  ",
	Field = "  ",
	Variable = "  ",
	Class = "  ",
	Interface = "  ",
	Module = "  ",
	Property = "  ",
	Unit = "  ",
	Value = "  ",
	Enum = "  ",
	Keyword = "  ",
	Snippet = "  ",
	Color = "  ",
	File = "  ",
	Reference = "  ",
	Folder = "  ",
	EnumMember = "  ",
	Constant = "  ",
	Struct = "  ",
	Event = "  ",
	Operator = "  ",
	TypeParameter = "  ",
}

cmp.setup({
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	experimental = {
		ghost_text = true,
		native_menu = false,
	},
	formatting = {
		format = lspkind.cmp_format({
			before = function(entry, vim_item)
				vim_item.kind = string.format("%s %s", vim_item.kind, cmp_kinds[vim_item.kind])
				vim_item.menu = ({
					nvim_lsp = "[LSP]",
					luasnip = "[Snippet]",
					buffer = "[Buffer]",
					path = "[Path]",
				})[entry.source.name]
				return vim_item
			end,
		}),
	},
	mapping = cmp.mapping.preset.insert({
    		['<C-Space>'] = cmp.mapping.complete(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.confirm({ select = true })
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<Up>'] = cmp.mapping.select_prev_item(),
		['<Down>'] = cmp.mapping.select_next_item(),
	}),
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
    		{ name = "buffer" },
    		{ name = "path" },
   	}, 
    experimental = {
      ghost_text = true,
    },
})

vim.cmd([[
highlight CmpPmenu guibg=#282c34 guifg=#abb2bf
highlight CmpPmenuSel guibg=#61afef guifg=#ffffff
highlight CmpItemAbbr guifg=#abb2bf
highlight CmpItemAbbrDeprecated guifg=#a0a1a7
highlight CmpItemKind guifg=#c678dd
highlight CmpItemMenu guifg=#56b6c2
]])

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local npairs = require('nvim-autopairs')

npairs.setup({
	check_ts = true,
	ts_config = {
		lua = { 'string', 'source' },
		javascript = { 'template_string' },
		java = false,
	}
})

cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

require("nvim-treesitter.configs").setup({
	ensure_installed = { "javascript", "typescript", "html", "css", "lua", "json" },
	sync_install = false,
	auto_install = true,
	ignore_install = {},

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
	autotag = {
		enable = true,
	},
	context_commentstring = {
		enable = true,
	},
})

local lspconfig = require('lspconfig')

lspconfig.html.setup({})
lspconfig.cssls.setup({})
lspconfig.tsserver.setup({})

local nvim_tree = require("nvim-tree")

nvim_tree.setup({
	update_focused_file = {
		enable = true,
		update_cwd = true,
	},
	view = {
		width = 30,
		side = 'left',
	},
	renderer = {
		icons = {
			glyphs = {
				default = "",
				symlink = "",
				git = {
					unstaged = "✗",
					staged = "✓",
					unmerged = "",
					renamed = "➜",
					untracked = "★",
					deleted = "",
					ignored = "◌",
				},
				folder = {
					default = "",
					open = "",
					empty = "",
					empty_open = "",
					symlink = "",
					symlink_open = "",
				},
			},
		},
	},
	filters = {
		dotfiles = true,
	},
	git = {
		enable = true,
		ignore = false,
	},
})

vim.cmd([[colorscheme tokyonight]])

vim.g.mapleader = " "

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true

vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.shell = "fish"
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" }) 
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.splitbelow = true 
vim.opt.splitright = true 
vim.opt.splitkeep = "cursor"
vim.opt.mouse = "a"
vim.opt.formatoptions:append({ "r" })


vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])
vim.cmd([[au BufNewFile,BufRead *.astro setf astro]])
vim.cmd([[au BufNewFile,BufRead Podfile setf ruby]])

if vim.fn.has("nvim-0.8") == 1 then
	vim.opt.cmdheight = 0
end

local map = vim.keymap.set

map("i", "<C-b>", "<ESC>^i", { desc = "Move to beginning of line" })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear highlights" })
map("n", ";", ":")
map("n", "ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map("n", "chc", "<cmd>Telescope colorscheme<cr>", { desc = "Change theme real time!" })
map("n", "tf", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle NvimTree" })
map("n", ";", "<cmd>FineCmdline<CR>", { noremap = true, silent = true })
map('n', '<leader>f', ':lua vim.lsp.buf.format({ async = true })<CR>', { noremap = true, silent = true })

local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.prettier.with({
            filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "html", "css" },
            extra_args = { "--tab-width", "2" },
        }),
    },
})


local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.prettier.with({
            filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "html", "css" },
            extra_args = { "--tab-width", "30" },
        }),
    },
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.html", "*.css", "*.js", "*.jsx", "*.ts", "*.tsx" },
    callback = function() vim.lsp.buf.format({ async = false }) end,
})

