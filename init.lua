-- Lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "\\lazy\\lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "main",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP และ Autocompletion
  { "neovim/nvim-lspconfig" }, -- LSP configurations
  { "hrsh7th/nvim-cmp" }, -- Autocompletion
  { "hrsh7th/cmp-nvim-lsp" }, -- LSP source for nvim-cmp
  { "hrsh7th/cmp-buffer" }, -- Buffer source for nvim-cmp
  { "hrsh7th/cmp-path" }, -- Path source for nvim-cmp
  { "L3MON4D3/LuaSnip" }, -- Snippet engine
  { "saadparwaiz1/cmp_luasnip" }, -- Snippet source for nvim-cmp

  -- Syntax Highlighting
  { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }, -- Treesitter for syntax highlighting

  -- Tailwind CSS
  { "tailwindlabs/tailwindcss-intellisense" },

  -- Other useful plugins
  { "nvim-telescope/telescope.nvim" }, -- Fuzzy finder
  { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }, -- FZF integration
  { "nvim-lualine/lualine.nvim" }, -- Status line
  { "nvim-tree/nvim-tree.lua" }, -- File explorer
  { "onsails/lspkind-nvim" }, -- LSP icons
  { "windwp/nvim-autopairs" }, -- Autopairs

  -- Icons for file explorer and status line
  { "nvim-tree/nvim-web-devicons" },

  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
  }
})


-- nvim-cmp setup
local cmp = require('cmp')
local lspkind = require('lspkind')
local luasnip = require('luasnip')

cmp.setup({
  window = {
    completion = {
      border = 'rounded',
      col = 0,
      side = 'right',
      winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None',
    },
    documentation = {
      border = 'rounded',
      col = 0,
      side = 'right',
      winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None',
    },
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- 'text' or 'symbol'
      maxwidth = 50, -- 50 columns
      ellipsis_char = '…',
      before = function(entry, vim_item)
        -- Define the icons for each source using Nerd Font icons
        local icons = {
          Text = "", -- Text
          Method = "ƒ", -- Method
          Function = "", -- Function
          Constructor = "", -- Constructor
          Field = "", -- Field
          Variable = "", -- Variable
          Class = "ﴯ", -- Class
          Interface = "", -- Interface
          Module = "", -- Module
          Property = "", -- Property
          Unit = "", -- Unit
          Value = "", -- Value
          Enum = "", -- Enum
          Keyword = "", -- Keyword
          Snippet = "", -- Snippet
          Color = "", -- Color
          File = "", -- File
          Reference = "", -- Reference
          Folder = "", -- Folder
          EnumMember = "", -- EnumMember
          Constant = "", -- Constant
          Struct = "", -- Struct
          Event = "", -- Event
          Operator = "", -- Operator
          TypeParameter = "ﴔ" -- TypeParameter
        }

        -- Set icon and menu
        vim_item.kind = string.format('%s %s', icons[vim_item.kind] or "", vim_item.kind)
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
  mapping = {
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, {'i', 's'}),
    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })
      else
        fallback()
      end
    end, {'i', 's'}),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {'i', 's'}),
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- Customize colors and appearance for completion popup
vim.cmd([[
highlight CmpPmenu guibg=#282c34 guifg=#abb2bf
highlight CmpPmenuSel guibg=#61afef guifg=#ffffff
highlight CmpItemAbbr guifg=#abb2bf
highlight CmpItemAbbrDeprecated guifg=#a0a1a7
highlight CmpItemKind guifg=#c678dd
highlight CmpItemMenu guifg=#56b6c2
]])

-- For better integration with nvim-autopairs
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local npairs = require('nvim-autopairs')

npairs.setup({
  check_ts = true,
  ts_config = {
    lua = {'string', 'source'},
    javascript = {'template_string'},
    java = false,
  }
})

cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)


-- Treesitter configuration
require("nvim-treesitter.configs").setup({
  ensure_installed = { "javascript", "typescript", "html", "css", "lua" },
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
})

-- LSP Configurations
local lspconfig = require("lspconfig")

lspconfig.tsserver.setup({})
lspconfig.html.setup({})
lspconfig.cssls.setup({})
lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- nvim-tree setup with icons
local nvim_tree = require("nvim-tree")

nvim_tree.setup({
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  view = {
    width = 70,
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

-- Auto format with Prettier on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {"*.js", "*.jsx", "*.ts", "*.tsx", "*.css", "*.scss", "*.html"},
  callback = function()
    vim.cmd([[%!prettier --stdin-filepath %]])
  end
})

-- Tailwind CSS configuration
vim.g.tailwindcss_enabled = true

-- Set colorscheme
vim.cmd([[colorscheme tokyonight]])

-- Options
vim.opt.number = true -- Show line numbers
vim.opt.wrap = false -- Disable line wrap

-- Key mappings
local map = vim.keymap.set

map("i", "<C-b>", "<ESC>^i", { desc = "Move to beginning of line" })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear highlights" })
map("n", ";", ":")
map("n", "ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map("n", "chc", "<cmd>Telescope colorscheme<cr>", { desc = "Change theme real time!" })
map("n", "tf", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle NvimTree" })

