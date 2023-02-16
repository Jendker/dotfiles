require "common"

-- Indicate first time installation
local packer_bootstrap = false

-- Check if packer.nvim is installed
-- Run PackerCompile if there are changes in this file
local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
  packer_bootstrap = true
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "plugins.lua",
  command = "source <afile> | PackerSync",
})
-- Install packages
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- Leap and dependency
  use {
    'ggandor/leap.nvim',
    requires = {{'tpope/vim-repeat'}},
  }
  use {
    'ggandor/leap-spooky.nvim',
    config = function()
      require'leap-spooky'.setup()
    end
  }
  use 'rhysd/clever-f.vim'
  -- Waiting for this to be fixed: https://github.com/neovim/neovim/pull/19035
  -- use {
  --   'ggandor/flit.nvim',
  --   config = function()
  --     require'flit'.setup()
  --   end
  -- }
  use 'tpope/vim-sleuth' -- automatically detect tabwidth
  -- move lines with Alt arrows
  use 'matze/vim-move'
  -- random
  use 'tpope/vim-commentary'
  use {
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  }
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'nvim-treesitter/nvim-treesitter-context'
  use 'AndrewRadev/splitjoin.vim'
  use({
    "gbprod/substitute.nvim",
    config = function()
      vim.keymap.set("n", "<leader>r", "<cmd>lua require('substitute').operator()<cr>", { noremap = true })
      vim.keymap.set("n", "<leader>rr", "<cmd>lua require('substitute').line()<cr>", { noremap = true })
      vim.keymap.set("n", "<leader>R", "<cmd>lua require('substitute').eol()<cr>", { noremap = true })
      vim.keymap.set("x", "<leader>r", "<cmd>lua require('substitute').visual()<cr>", { noremap = true })
    end
  })
  use 'mg979/vim-visual-multi'
  -- without VSCode
      -- auto trail whitespace
      use {
          'lewis6991/spaceless.nvim',
          config = function()
              require'spaceless'.setup()
          end,
          cond = not_vscode
      }
      use {'tpope/vim-fugitive', cond = not_vscode}
      use {
        'navarasu/onedark.nvim',
        config = function()
          require('onedark').setup{
            transparent = true
          }
          require('onedark').load()
        end,
        cond = not_vscode
      }
      use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true},
        config = function() require("lualine").setup(
          {sections = {lualine_x = {'filetype'}}, options = {theme = 'wombat', section_separators = '', component_separators = ''}})
        end,
        cond = not_vscode
      }
      use {
        'lukas-reineke/indent-blankline.nvim',
        config = function()
          require("indent_blankline").setup {
            char = '┊',
          }
        end,
        cond = not_vscode
      }
      use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { {'nvim-lua/plenary.nvim'} },
        cond = not_vscode
      }
      use {'farmergreg/vim-lastplace', cond = not_vscode}
      use {
        'karb94/neoscroll.nvim',
        config = function()
          require('neoscroll').setup()
        end,
        cond = not_vscode
      }
      use {
        'windwp/nvim-autopairs',
        config = function() require('nvim-autopairs').setup {} end,
        cond = not_vscode
      }
      use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
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
        },
        after = 'nvim-autopairs',
        config = function()
          local lsp = require('lsp-zero').preset({
            name = 'recommended',
            suggest_lsp_servers = false,
            set_lsp_keymaps = {preserve_mappings = false}
          })

          local cmp = require('cmp')
          local cmp_mappings = lsp.defaults.cmp_mappings({
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<Tab>'] = cmp.mapping.confirm(),
            ['<S-Tab>'] = nil,
          })
          lsp.setup_nvim_cmp({
            mapping = cmp_mappings
          })

          lsp.ensure_installed({
            -- list of servers in
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
            'bashls',
            'clangd',
            'pyright',
            'lua_ls',
            'yamlls',
          })
          local lsp_signature_config = {
            toggle_key = '<C-h>'
          }
          lsp.on_attach(function(_, bufnr)
            require('lsp_signature').on_attach(lsp_signature_config, bufnr)
          end)
          lsp.nvim_workspace()
          lsp.setup()
          -- If you want to insert `(` after selected function
          local ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
          if ok then
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
          end
        end,
        cond = not_vscode
      }
      use {
        'lewis6991/gitsigns.nvim',
        tag = 'release',
        cond = not_vscode
      }
      use {
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
      }

  if packer_bootstrap then
    require("packer").sync()
  end
end)
