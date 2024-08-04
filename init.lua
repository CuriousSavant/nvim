-- Lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "\\lazy\\lazy.nvim"

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

vim.cmd [[autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })]]

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
  { "windwp/nvim-ts-autotag" },

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
        vim_item.kind = string.format("%s %s", vim_item.kind, cmp_kinds[vim_item.kind]) -- icons
        -- Set icon and menu
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
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }), -- เรียก autocomplete
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- ยืนยันการเลือกด้วย Enter
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true }) -- ยืนยันการเลือกด้วย Tab
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item() -- เลือกไอเท็มก่อนหน้า
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<Up>'] = cmp.mapping.select_prev_item(), -- เลือกไอเท็มก่อนหน้าด้วยลูกศรขึ้น
    ['<Down>'] = cmp.mapping.select_next_item(), -- เลือกไอเท็มถัดไปด้วยลูกศรลง
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
  ensure_installed = { "javascript", "typescript", "html", "css", "lua", "json" }, 
  sync_install = false, -- ติดตั้ง languages แบบ synchronous
  auto_install = true, -- ติดตั้ง languages อัตโนมัติเมื่อเปิดไฟล์ที่ยังไม่มีการติดตั้ง
  ignore_install = {}, -- รายชื่อ parsers ที่ไม่ต้องการติดตั้ง

  highlight = {
    enable = true, -- เปิดใช้งาน syntax highlighting
    additional_vim_regex_highlighting = false, -- ไม่ใช้ regex-based highlighting
  },
  indent = {
    enable = true, -- เปิดใช้งานการจัดรูปแบบการย่อหน้าอัตโนมัติ
  },
  autotag = {
    enable = true, -- เพิ่มแท็กปิดอัตโนมัติสำหรับ HTML, XML
  },
  context_commentstring = {
    enable = true, -- เปลี่ยนวิธีการใส่คอมเมนต์ตาม context ของไฟล์
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

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*js", "*.ts", "*.jsx", "*.tsx", "*.html", "*.css"},
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
    end,
})


vim.o.updatetime = 300
vim.o.timeoutlen = 500

-- Disable file changed warning
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.backup = false


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
