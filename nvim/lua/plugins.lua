require "common"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  {
    'ggandor/leap.nvim',
    dependencies = {{'tpope/vim-repeat'}},
  },
  {
    'ggandor/leap-spooky.nvim',
    config = function()
      require'leap-spooky'.setup()
    end
  },
  'rhysd/clever-f.vim',
  -- Waiting for this to be fixed: https://github.com/neovim/neovim/pull/19035
  -- {
  --   'ggandor/flit.nvim',
  --   config = function()
  --     require'flit'.setup()
  --   end
  -- },
  'tpope/vim-sleuth', -- automatically detect tabwidth
  'matze/vim-move',   -- move lines with Alt arrows
  'tpope/vim-commentary',  -- gcc to comment
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
  },
  'nvim-treesitter/nvim-treesitter-textobjects',
  'nvim-treesitter/nvim-treesitter-context',
  'AndrewRadev/splitjoin.vim',
  {
    "gbprod/substitute.nvim",
    config = function()
      vim.keymap.set("n", "<leader>r", "<cmd>lua require('substitute').operator()<cr>", { noremap = true })
      vim.keymap.set("n", "<leader>rr", "<cmd>lua require('substitute').line()<cr>", { noremap = true })
      vim.keymap.set("n", "<leader>R", "<cmd>lua require('substitute').eol()<cr>", { noremap = true })
      vim.keymap.set("x", "<leader>r", "<cmd>lua require('substitute').visual()<cr>", { noremap = true })
    end
  },
  'mg979/vim-visual-multi',
  -- without VSCode
      -- auto trail whitespace
      {
          'lewis6991/spaceless.nvim',
          config = function()
              require'spaceless'.setup()
          end,
          cond = not_vscode
      },
      {'tpope/vim-fugitive', cond = not_vscode},
      {
        'navarasu/onedark.nvim',
        lazy = false, -- make sure we load this during startup, that's main colorscheme
        config = function()
          require('onedark').setup{
            transparent = true
          }
          require('onedark').load()
        end,
        cond = not_vscode
      },
      {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true},
        config = function() require("lualine").setup(
          {sections = {lualine_x = {'filetype'}}, options = {theme = 'wombat', section_separators = '', component_separators = ''}})
        end,
        cond = not_vscode
      },
      {
        'lukas-reineke/indent-blankline.nvim',
        config = function()
          require("indent_blankline").setup {
            char = '┊',
          }
        end,
        cond = not_vscode
      },
      {
        'nvim-telescope/telescope.nvim', version = '0.1.1',
        dependencies = { {'nvim-lua/plenary.nvim'} },
        cond = not_vscode
      },
      {'farmergreg/vim-lastplace', cond = not_vscode},
      {
        'karb94/neoscroll.nvim',
        config = function()
          require('neoscroll').setup()
        end,
        cond = not_vscode
      },
      {
        'windwp/nvim-autopairs',
        lazy = false,
        config = function() require('nvim-autopairs').setup {} end,
        cond = not_vscode
      },
      {
        'VonHeikemen/lsp-zero.nvim',
        dependencies = {
          -- LSP Support
          {'neovim/nvim-lspconfig'},
          {'williamboman/mason.nvim'},
          {'williamboman/mason-lspconfig.nvim'},

          -- Autocompletion
          {'hrsh7th/nvim-cmp'},
          {'hrsh7th/cmp-buffer'},
          {'hrsh7th/cmp-path'},
          {'saadparwaiz1/cmp_luasnip'},
          {'hrsh7th/cmp-nvim-lsp'},
          {'hrsh7th/cmp-nvim-lua'},

          -- Snippets
          {'L3MON4D3/LuaSnip'},
          {'rafamadriz/friendly-snippets'},

          -- Added by me
          {'ray-x/lsp_signature.nvim'},
          {'nvim-autopairs'}
        },
        cond = not_vscode
      },
      {
        'lewis6991/gitsigns.nvim',
        tag = 'release',
        cond = not_vscode
      },
      {
        "folke/which-key.nvim",
        config = function()
          vim.o.timeout = true
          vim.o.timeoutlen = 500
          require("which-key").setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
          }
        end,
        cond = not_vscode
      },
      {
        "mbbill/undotree",
        config = function()
          map("n", "<leader>u", vim.cmd.UndotreeToggle)
        end,
        cond = not_vscode
      }
}

require("lazy").setup(plugins)
