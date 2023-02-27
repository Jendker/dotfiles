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
      vim.keymap.set("n", "gr", "<cmd>lua require('substitute').operator()<cr>", { noremap = true })
      vim.keymap.set("n", "grr", "<cmd>lua require('substitute').line()<cr>", { noremap = true })
      vim.keymap.set("n", "gR", "<cmd>lua require('substitute').eol()<cr>", { noremap = true })
      vim.keymap.set("x", "gr", "<cmd>lua require('substitute').visual()<cr>", { noremap = true })
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
      {
        'tpope/vim-fugitive',
        dependencies = {'tpope/vim-rhubarb', 'shumphrey/fugitive-gitlab.vim'},
        config = function()
          -- to open Roboception remote url:
          vim.g.fugitive_gitlab_domains = {'https://gitlab.com', 'https://gitlab.roboception.de'}
        end,
        cond = not_vscode
      },
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
              lualine_c = {
                {
                  'filename',
                  file_status = true, -- displays file status (readonly status, modified status)
                  path = 1 -- 0 = just filename, 1 = relative path, 2 = absolute path
                }
              },
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
        "MattesGroeger/vim-bookmarks",
        config = function()
          vim.g.bookmark_no_default_key_mappings = 1
          vim.g.bookmark_save_per_working_dir = 1
          vim.g.bookmark_sign = ""
          vim.keymap.set('n', '<Leader><Leader>', '<Plug>BookmarkToggle', { desc = "Bookmark toggle" })
          vim.keymap.set('n', '<Leader>bi', '<Plug>BookmarkAnnotate', { desc = "Bookmark annotate" })
          vim.keymap.set('n', '<Leader>bj', '<Plug>BookmarkNext', { desc = "Bookmark next" })
          vim.keymap.set('n', '<Leader>bk', '<Plug>BookmarkPrev', { desc = "Bookmark previous" })
        end,
        cond = not_vscode
      },
      {
        "tom-anders/telescope-vim-bookmarks.nvim",
        cond = not_vscode
      },
      {
        'nvim-telescope/telescope.nvim', version = '0.1.1',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
          local telescope = require('telescope')
          telescope.setup()
          -- vim_booksmarks
          telescope.load_extension('vim_bookmarks')
          vim.keymap.set('n', '<leader>ba', telescope.extensions.vim_bookmarks.all, { desc = "Show [b]ookmarks in [a]ll files" })
          vim.keymap.set('n', '<leader>bc', telescope.extensions.vim_bookmarks.current_file, { desc = "Show [b]ookmarks in [c]urrent file" })
        end,
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
            views = {
              mini = {
                timeout = 3500
              }
            },
            commands = {
              history = {
                filter = {
                  any = {
                    { event = "notify" },
                    { error = true },
                    { warning = true },
                    { event = "msg_show", kind = "" },
                    { event = "msg_show", kind = "echo" },
                    { event = "lsp", kind = "message" },
                  },
                },
              },
              -- :Noice last
              last = {
                filter = {
                  any = {
                    { event = "notify" },
                    { error = true },
                    { warning = true },
                    { event = "msg_show", kind = "" },
                    { event = "msg_show", kind = "echo" },
                    { event = "lsp", kind = "message" },
                  },
                },
                filter_opts = { count = 1 },
              },
            }
          })
        end,
        keys = {
          { "<leader>ol", function() require("noice").cmd("last") end, desc = "N[o]ice [l]ast message" },
          { "<leader>oh", function() require("noice").cmd("history") end, desc = "N[o]ice [h]istory" },
          { "<leader>oa", function() require("noice").cmd("all") end, desc = "N[o]ice [a]ll" },
        },
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
      },
}

require("lazy").setup(plugins)
