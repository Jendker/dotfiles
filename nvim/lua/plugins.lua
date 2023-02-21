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
    config = function ()
      local leap = require('leap')
      leap.set_default_keymaps()
      leap.opts.safe_labels = {}
    end,
    dependencies = {{'tpope/vim-repeat'}},
  },
  {
    'ggandor/leap-spooky.nvim',
    config = function()
      require'leap-spooky'.setup()
    end
  },
  {
    'rhysd/clever-f.vim',
    config = function ()
      vim.g.clever_f_smart_case = 1
    end
  },
  -- Waiting for this to be fixed: https://github.com/neovim/neovim/pull/19035
  -- {
  --   'ggandor/flit.nvim',
  --   config = function()
  --     require'flit'.setup()
  --   end
  -- },
  'tpope/vim-sleuth', -- automatically detect tabwidth
  'matze/vim-move',   -- move lines with Alt arrows
  {
    'tpope/vim-commentary', -- gcc to comment
    config = function ()
      -- Comment c, cpp, cs, java with //
      vim.api.nvim_command([[autocmd FileType c,cpp,cs,java setlocal commentstring=//\ %s]])
    end
  },
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
        config = function()
          -- specify lualine_x depending on existance of Noice plugin
          local lualine_x = {}
          local is_ok, noice = pcall(require, 'noice')
          if is_ok then
            lualine_x = {
              {
                noice.api.status.mode.get,
                cond = function()
                  -- Don't show if status is e.g. -- INSERT -- or -- VISUAL LINE --
                  return noice.api.status.mode.has() and noice.api.status.mode.get():find("^-- .+ --$") == nil
                end,
              },
            }
          end
          table.insert(lualine_x, {'filetype'})
          -- lualine_x definition done
          require("lualine").setup(
          {
            sections = {
              lualine_x = lualine_x,
            },
            options = {theme = 'wombat', section_separators = '', component_separators = ''},
          })
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
        -- Reserve space for diagnostic icons
        config = function() vim.opt.signcolumn = 'yes' end,
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
          vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR><C-w>h<CR>")
          vim.opt.undofile = true
        end,
        cond = not_vscode
      },
      {
        "folke/noice.nvim",
        dependencies = {
          "MunifTanjim/nui.nvim",
        },
        config = function()
          require("noice").setup({
            lsp = {
              -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
              override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
              },
              signature = {
                enabled = false
              }
            },
            -- you can enable a preset for easier configuration
            presets = {
              bottom_search = true, -- use a classic bottom cmdline for search
              command_palette = true, -- position the cmdline and popupmenu together
              long_message_to_split = true, -- long messages will be sent to a split
            },
            messages = {
              enabled = true,
              view_search = "mini",
            },
            notify = {
              enabled = false
            }
          })
        end,
        cond = not_vscode
      },
      {
        "907th/vim-auto-save",
        config = function()
          vim.g.auto_save = 0
          vim.g.auto_save_silent = 1
          vim.keymap.set("n", "<leader>n", vim.cmd.AutoSaveToggle, { desc = "[n] Toggle autosave", silent = true})
        end,
        cond = not_vscode
      }
}

require("lazy").setup(plugins)
