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
    event = 'VeryLazy',
    config = function ()
      local leap = require('leap')
      leap.set_default_keymaps()
      leap.opts.safe_labels = {}
    end,
    dependencies = {'tpope/vim-repeat'},
  },
  {
    'ggandor/leap-spooky.nvim',
    event = 'VeryLazy',
    config = function()
      require'leap-spooky'.setup()
    end
  },
  {
    'rhysd/clever-f.vim',
    event = 'VeryLazy',
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
  {
    'tpope/vim-commentary', -- gcc to comment
    event = 'VeryLazy',
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
    config = function()
      require 'config_plugins.treesitter'
    end,
    build = ':TSUpdate',
  },
  'nvim-treesitter/nvim-treesitter-textobjects',
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require 'treesitter-context'.setup{enable = not vscode}
    end
  },
  {'andymass/vim-matchup', cond = not_vscode},  -- better % on matching delimeters
  'HiPhish/nvim-ts-rainbow2',  -- colored brackets
  {
    "kana/vim-textobj-user",
    event = 'VeryLazy',
    dependencies = {
      "kana/vim-textobj-entire",             -- e - entire
      "kana/vim-textobj-line",               -- l - line
      "kana/vim-textobj-indent",             -- i - indent block, I - same indent (won't select sub indent)
      "Julian/vim-textobj-variable-segment", -- v - segment
    },
  },
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = { 'gJ', 'gS' },
    config = function()
      local treesj = require('treesj')
      treesj.setup({
        use_default_keymaps = false,
        max_join_length = 100,
      })
      vim.keymap.set('n', 'gJ', treesj.join, {desc = "[J]oin lines"})
      vim.keymap.set('n', 'gS', treesj.split, {desc = "[S]plit lines"})
    end,
  },
  {
    "gbprod/substitute.nvim",
    version = "*",
    config = function()
      local substitute = require("substitute")
      substitute.setup()
      vim.keymap.set("n", "gr", substitute.operator, { noremap = true, desc = "[r]eplace <motion>" })
      vim.keymap.set("n", "grr", substitute.line, { noremap = true, desc = "[r]eplace whole line"})
      vim.keymap.set("n", "gR", substitute.eol, { noremap = true,  desc = "[R]eplace until end of line"})
      vim.keymap.set("x", "gr", substitute.visual, { noremap = true, desc = "[r]eplace selected"})
    end
  },
  'mg979/vim-visual-multi',
  {"haya14busa/is.vim", event = 'VeryLazy'}, -- auto hide highlight after search
  -- without VSCode
      -- auto trail whitespace
      {
          'lewis6991/spaceless.nvim',
          event = 'VeryLazy',
          config = function()
              require'spaceless'.setup()
          end,
          cond = not_vscode
      },
      {
        'tpope/vim-fugitive',
        event = 'VeryLazy',
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
          local onedark = require('onedark')
          onedark.setup{
            transparent = true,
            toggle_style_list = { 'light', 'dark' }, -- List of styles to toggle between
          }
          onedark.load()
          vim.keymap.set('n', '<leader>tt', function()
            onedark.setup({transparent = not vim.g.onedark_config.transparent})
            onedark.load()
            onedark.toggle()
          end, {desc = "Toggle dark and light mode"})
        end,
        cond = not_vscode
      },
      {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true},
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
            options = {theme = 'onedark', section_separators = '', component_separators = ''},
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
        event = 'VeryLazy',
        cond = not_vscode
      },
      {
        'nvim-telescope/telescope.nvim', version = '0.1.1',
        cmd = 'Telescope',
        keys = {
          {'<leader>ba', "<cmd>lua telescope.extensions.vim_bookmarks.all()<cr>", 'n', desc = "Show [b]ookmarks in [a]ll files"},
          {'<leader>bc', "<cmd>lua telescope.extensions.vim_bookmarks.current_file()<cr>", 'n', desc = "Show [b]ookmarks in [c]urrent file"},
          {'<leader>sf', "<cmd>lua require('telescope.builtin').find_files()<cr>", 'n', desc = '[S]earch [f]iles'},
          {'<leader>sl', "<cmd>lua require('telescope.builtin').live_grep()<cr>", 'n', desc = '[S]earch with [l]ive grep'},
          {'<leader>sg', "<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input('Grep > ') })<cr>", 'n', desc = "[S]earch after [g]rep with string"},
          {'<leader>si', "<cmd>lua require('telescope.builtin').git_files()<cr>", 'n', desc = '[S]earch in g[i]t files'},
          {'<leader>sb', "<cmd>lua require('telescope.builtin').buffers()<cr>", 'n', desc = '[S]earch existing [b]uffers'},
          {'<leader>sh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", 'n', desc = '[S]earch [h]elp'},
          {'<leader>sd', "<cmd>lua require('telescope.builtin').diagnostics()<cr>", 'n', desc = '[S]earch [d]iagnostics'},
          {'<leader>so', "<cmd>lua require('telescope.builtin').oldfiles()<cr>", 'n', desc = '[S]earch recently [o]pened files'},
          {'<leader>sr', "<cmd>lua require('telescope.builtin').resume()<cr>", 'n', { desc = '[S]earch [r]esume'}},
          {'<leader>/', desc = '[?] search for word under cursor'},
          {'<leader>?', desc = '[/] Fuzzily search in current buffer'},
        },
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
          local telescope = require('telescope')
          local actions = require('telescope.actions')
          local trouble = require("trouble.providers.telescope")
          telescope.setup({
            defaults = {
              path_display={"smart"},
              mappings = {
                i = { ["<c-t>"] = trouble.open_with_trouble },
                n = { ["<c-t>"] = trouble.open_with_trouble },
              },
              layout_config = {
                horizontal = {
                  width = 0.95,
                  preview_width = 0.5,
                }
              },
            },
            pickers = {
              live_grep = {
                mappings = {
                  i = {
                    ["<C-Down>"] = function(...)
                      return actions.cycle_history_next(...)
                    end,
                    ["<C-Up>"] = function(...)
                      return actions.cycle_history_prev(...)
                    end,
                    ["<C-f>"] = function(...)
                      return actions.preview_scrolling_down(...)
                    end,
                    ["<C-b>"] = function(...)
                      return actions.preview_scrolling_up(...)
                    end,
                    ["<c-r>"] = actions.to_fuzzy_refine,
                  },
                  n = {
                    ["q"] = function(...)
                      return actions.close(...)
                    end,
                  },
                },
              },
            },
          })
          -- vim_booksmarks
          telescope.load_extension('vim_bookmarks')
          vim.keymap.set('n', '<leader>?', require('telescope.builtin').grep_string, { desc = '[?] search for word under cursor'})
          vim.keymap.set('n', '<leader>/', function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
              winblend = 10,
              previewer = false,
            })
          end, { desc = '[/] Fuzzily search in current buffer' })
        end,
        cond = not_vscode
      },
      {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = {"kkharji/sqlite.lua", "nvim-telescope/telescope.nvim"},
        keys = {
          {"<leader>sp", "<Cmd>lua require('telescope').extensions.frecency.frecency({ workspace = 'CWD' })<CR>", "n", noremap = true, silent = true, desc = "Telescope frecency"},
        },
        config = function()
          require"telescope".load_extension("frecency")
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
        event = 'VeryLazy',
        lazy = false,
        config = function() require('nvim-autopairs').setup {} end,
        cond = not_vscode
      },
      {
        'VonHeikemen/lsp-zero.nvim', branch = 'v2.x',
        dependencies = {
          -- LSP Support
          {'neovim/nvim-lspconfig'},
          {
            'williamboman/mason.nvim',
            build = function() pcall(vim.cmd, 'MasonUpdate') end,
          },
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
          {'jose-elias-alvarez/null-ls.nvim'}
        },
        cond = not_vscode
      },
      {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig",
        config = function ()
          require("nvim-navic").setup {
            icons = {
              File = ' ',
              Module = ' ',
              Namespace = ' ',
              Package = ' ',
              Class = ' ',
              Method = ' ',
              Property = ' ',
              Field = ' ',
              Constructor = ' ',
              Enum = ' ',
              Interface = ' ',
              Function = ' ',
              Variable = ' ',
              Constant = ' ',
              String = ' ',
              Number = ' ',
              Boolean = ' ',
              Array = ' ',
              Object = ' ',
              Key = ' ',
              Null = ' ',
              EnumMember = ' ',
              Struct = ' ',
              Event = ' ',
              Operator = ' ',
              TypeParameter = ' '
            },
            highlight = true,
          }
        end,
        cond = not_vscode
      },
      {
        'lewis6991/gitsigns.nvim',
        event = { "BufReadPre", "BufNewFile" },
        config = function()
          require 'config_plugins.gitsigns'
        end,
        tag = 'release',
        cond = not_vscode
      },
      {
        "folke/which-key.nvim",
        config = function()
          vim.o.timeout = true
          vim.o.timeoutlen = 500
          require("which-key").setup {
            plugins = { spelling = true },
          }
        end,
        cond = not_vscode
      },
      {
        "mbbill/undotree",
        event = "VeryLazy",
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
              hover = {
                enabled = false
              },
              signature = {
                enabled = false,
              },
              progress = {
                enabled = false,
              }
            },
            -- you can enable a preset for easier configuration
            presets = {
              bottom_search = true, -- use a classic bottom cmdline for search
              command_palette = true, -- position the cmdline and popupmenu together
              long_message_to_split = false, -- if long messages should be sent to a split
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
                    { event = "msg_show", kind = {"", "echo" } },
                    { event = "lsp", kind = "message" },
                  },
                },
                filter_opts = { count = 500 },
              },
              -- :Noice last
              last = {
                filter = {
                  any = {
                    { event = "notify" },
                    { error = true },
                    { warning = true },
                    { event = "msg_show", kind = {"", "echo" } },
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
          { "<leader>om", "<cmd>:messages<cr>", desc = ":messages" },
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
      {"petertriho/nvim-scrollbar", cond = not_vscode, config = function() require("scrollbar").setup({hide_if_all_visible = true}) end},
      {"tpope/vim-sleuth", cond = not_vscode}, -- automatically detect tabwidth
      {"iamcco/markdown-preview.nvim",
        build = function() vim.fn["mkdp#util#install"]() end,
        init = function()
          vim.g.mkdp_preview_options={ ["disable_sync_scroll"] = 0 }
          vim.g.mkdp_page_title = 'Preview: ${name}'
        end,
        config = function()
          vim.keymap.set('n', '<leader>bp', "<cmd>MarkdownPreview<cr>", { desc = "Markdown [b]uffer [p]review" })
        end,
        ft = { "markdown" },
        cond = not_vscode
      },
      {
        "iamcco/markdown-preview.nvim",
        build = function() vim.fn["mkdp#util#install"]() end,
      },
      {"wintermute-cell/gitignore.nvim", cmd = 'Gitignore', dependencies = { "nvim-telescope/telescope.nvim" }, cond = not_vscode},
      {
        -- config from https://www.lazyvim.org/plugins/editor#troublenvim
        "folke/trouble.nvim",
        cmd = { "TroubleToggle", "Trouble" },
        opts = { use_diagnostic_signs = true },
        keys = {
          { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
          { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
          { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
          { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
          {
            "[q",
            function()
              if require("trouble").is_open() then
                require("trouble").previous({ skip_groups = true, jump = true })
              else
                pcall(vim.cmd, 'cprev')
              end
            end,
            desc = "Previous trouble/quickfix item",
          },
          {
            "]q",
            function()
              if require("trouble").is_open() then
                require("trouble").next({ skip_groups = true, jump = true })
              else
                pcall(vim.cmd, 'cnext')
              end
            end,
            desc = "Next trouble/quickfix item",
          },
        },
        cond = not_vscode
      },
      {'lambdalisue/suda.vim', cmd = {'SudaRead', 'SudaWrite'}, cond = not_vscode},
      {
        "dnlhc/glance.nvim",
        cmd = 'Glance',
        config = function()
          local glance = require('glance')
          local actions = glance.actions
          glance.setup({
            border = {
              enable = true, -- Show window borders. Only horizontal borders allowed
            },
            hooks = {
              -- don't show glance if there is only one result
              before_open = function(results, open, jump, _)
                if #results == 1 then
                  jump(results[1]) -- argument is optional
                else
                  open(results) -- argument is optional
                end
              end,
            },
            mappings = {
              list = {
                ['l'] = actions.open_fold,
                ['h'] = actions.close_fold,
              },
            },
          })
        end,
        cond = not_vscode
      },
      {
        'Exafunction/codeium.vim',
        event = { "BufReadPre", "BufNewFile" },
        init = function()
          -- disable by default - enable manually in machine_settings.lua
          vim.g.codeium_enabled = false
        end,
        config = function()
          vim.keymap.set('i', '<a-]>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, desc = "Codeium next suggestion" })
          vim.keymap.set('i', '<a-[>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, desc = "Codeium previous suggestion"})
          vim.keymap.set('i', '<a-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, desc = "Codeium clear suggestion" })
          vim.keymap.set('i', '<a-Bslash>', function() return vim.fn['codeium#Complete']() end, { expr = true, desc = "Codeium trigger complete"})
        end,
        cond = not_vscode
      },
}

require("lazy").setup(plugins)
