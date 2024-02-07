local common = require('common')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
    'rhysd/clever-f.vim',
    event = 'VeryLazy',
    config = function()
      vim.g.clever_f_smart_case = 1
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          enabled = false,
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "v" }, function() require("flash").jump() end, desc = "Flash" },
      { "<c-s>", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
    config = function(_, opts)
      local flash = require('flash')
      flash.setup(opts)
      flash.toggle(false) -- disable flash in search
    end
  },
  {
    'tpope/vim-commentary', -- gcc to comment
    event = 'VeryLazy',
    init = function ()
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
  -- treesitter stuff
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require 'config_plugins.treesitter'
    end,
    build = ':TSUpdate',
  },
  'nvim-treesitter/nvim-treesitter-textobjects',
  { -- better % on matching delimeters
    'andymass/vim-matchup',
    init = function()
      vim.g.matchup_motion_enabled = not vscode
      vim.g.matchup_matchparen_enabled = not vscode
      vim.g.matchup_matchparen_pumvisible = 0 -- to fix cmp-nvim autocomplete with codeium
    end
  },
  {
    "kana/vim-textobj-user",
    event = 'VeryLazy',
    dependencies = {
      "kana/vim-textobj-entire",             -- e - entire
      "kana/vim-textobj-line",               -- l - line
      "Julian/vim-textobj-variable-segment", -- v - segment
    },
  },
  "wellle/targets.vim",
  -- end treesitter stuff
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = { 'gJ', 'gS' },
    config = function()
      local treesj = require('treesj')
      treesj.setup({
        use_default_keymaps = false,
        max_join_length = 120,
      })
      vim.keymap.set('n', 'gJ', treesj.join, {desc = "[J]oin lines"})
      vim.keymap.set('n', 'gS', treesj.split, {desc = "[S]plit lines"})
    end,
  },
  {
    "gbprod/substitute.nvim",
    version = "*",
    opts = {
      highlight_substituted_text = {
        enabled = not_vscode(),
      },
    },
    config = function(_, opts)
      local substitute = require("substitute")
      substitute.setup(opts)
      vim.keymap.set("n", "gr", substitute.operator, { noremap = true, desc = "[r]eplace <motion>" })
      vim.keymap.set("n", "grr", substitute.line, { noremap = true, desc = "[r]eplace whole line"})
      vim.keymap.set("n", "gR", substitute.eol, { noremap = true,  desc = "[R]eplace until end of line"})
      vim.keymap.set("x", "gr", substitute.visual, { noremap = true, desc = "[r]eplace selected"})
    end
  },
  {
    'mg979/vim-visual-multi',
    init = function()
      -- https://github.com/mg979/vim-visual-multi/issues/172
      vim.g.VM_maps = {
        ["I BS"] = '',      -- disable backspace mapping which conflicts with nvim-autopairs
        ["Exit"] = '<C-C>', -- quit VM
      }
    end,
    config = function()
      -- https://github.com/nvim-lualine/lualine.nvim/issues/951
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = 'visual_multi_start',
        callback = function()
          require('lualine').hide()
        end
      })

      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = 'visual_multi_exit',
        callback = function()
          require('lualine').hide({ unhide = true })
        end
      })
    end
  },
  {"romainl/vim-cool", event = 'BufReadPost'}, -- auto hide highlight after search
  {
    'tzachar/highlight-undo.nvim',
    config = true
  },
  -- without VSCode
  -- auto trail whitespace
  {
      'lewis6991/spaceless.nvim',
      event = 'VeryLazy',
      cond = not_vscode
  },
  {
    'tpope/vim-fugitive',
    event = 'VeryLazy',
    dependencies = {'tpope/vim-rhubarb', 'shumphrey/fugitive-gitlab.vim'},
    config = function()
      -- to open Roboception remote url:
      vim.g.fugitive_gitlab_domains = {'https://gitlab.com', 'https://gitlab.roboception.de'}
      vim.keymap.set("n", "<leader>hM", function()
          local main_branch_name = common.getGitMainBranch()
          if main_branch_name ~= nil then
            local file_path = vim.fn.expand('%')
            vim.cmd("NewCleanBufferInSplit")
            vim.cmd("Gedit " .. main_branch_name .. ":" .. file_path)
          else
            vim.api.nvim_err_writeln("Not a git repository")
          end
        end,
        { desc = "Current file main version" })
    end,
    cond = not_vscode
  },
  {
    'junegunn/gv.vim',
    cmd = 'GV',
    keys = {
      {"<leader>gv", "<cmd>GV<cr>", mode = 'n', desc = "Git commit browser"},
      {"<leader>gv", "<cmd>'<,'>GV<cr>", mode = 'v', desc = "Git commit browser"},
    },
    dependencies = 'tpope/vim-fugitive',
    cond = not_vscode
  },
  {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = false,
      delete_to_trash = true,
      keymaps = {
        ["<leader>o"] = function()
          local oil = require("oil")
          local cwd = oil.get_current_dir()
          local entry = oil.get_cursor_entry()
          if cwd and entry then
            common.openWithDefault(string.format("%s/%s", cwd, entry.name))
          end
        end,
      },
    },
    config = function(_, opts)
      local oil = require("oil")
      oil.setup(opts)
      vim.keymap.set("n", "<leader>pv", oil.open, { desc = "Open directory view" })
    end,
    cond = not_vscode
  },
  {
    'rebelot/kanagawa.nvim',
    event = 'VeryLazy',
    opts = {
      undercurl = false,
      transparent = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none"
            }
          }
        }
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          -- vim-illuminate highlights
          IlluminatedWordText = { bg = theme.ui.bg_p2 },
          IlluminatedWordRead = { bg = theme.ui.bg_p2 },
          IlluminatedWordWrite = { bg = theme.ui.bg_p2 },

          -- This will make floating windows look nicer with default borders
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },
          TelescopeBorder = { bg = "none" },
          TelescopeTitle = { bg = "none" },
          NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
          LazyNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
          MasonNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
        }
      end,
    },
    config = function(_, opts)
      require('kanagawa').setup(opts)
    end,
    cond = not_vscode
  },
  {
    'navarasu/onedark.nvim',
    priority = 100,
    config = function()
      local onedark = require('onedark')
      onedark.setup{
        transparent = not tmux,
        toggle_style_list = { 'light', 'dark' }, -- List of styles to toggle between
        diagnostics = {
          undercurl = false,
        },
        highlights = {
          IlluminatedWordText = {bg = '$bg2'},
          IlluminatedWordRead = {bg = '$bg2'},
          IlluminatedWordWrite = {bg = '$bg2'},
          IblIndent = { fg = '$bg3', fmt = "nocombine" },
          MsgArea = { fg = '$fg' },
          MatchParen = {fg = '$orange', bg = 'none', fmt = "bold" },
          -- winbar needs to be set on current nightly
          -- TODO check if this is still needed https://github.com/neovim/neovim/issues/26378
          WinBar = { fg = "none", bg = "none", fmt = "bold" },
          WinBarNC = { fg = "none", bg = "none", fmt = "bold" },
          -- make floating windows transparent
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          -- but keep background for Lazy and Mason
          LazyNormal = { fg = '$fg', bg = '$bg1' },
          MasonNormal = { fg = '$fg', bg = '$bg1' },
        }
      }
      onedark.load()
      vim.keymap.set('n', '<leader>tt', function()
        onedark.setup({transparent = not vim.g.onedark_config.transparent and not tmux})
        onedark.toggle()
        require('highlight-undo').setup()
      end, {desc = "Toggle dark and light mode"})
    end,
    cond = not_vscode
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true},
    config = function()
      vim.opt.showmode = false -- don't display mode, e.g. '-- INSERT --', lualine takes care of it
      local lualine_x = {}
      table.insert(lualine_x,
        {
          function()
            local function split_string(input, delimiter)
              local result = {}
              for part in string.gmatch(input, "([^" .. delimiter .. "]+)") do
                table.insert(result, part)
              end
              return result
            end
            local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_DEFAULT_ENV
            if venv then
              local params = split_string(venv, '/')
              return '(' .. params[#params] .. ')'
            else
              return ''
            end
          end,
          cond = function() return vim.bo.filetype == "python" end,
        })
      table.insert(lualine_x,
        {
          function()
            if vim.g.autosave_on == 1 then
              return "󱑜"
            else
              return ""
            end
          end
        })
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
    main = "ibl",
    opts = {
      indent = {
        char = "┊",
        tab_char = "┊",
      },
      exclude = {
        filetypes = {
          "help",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "lspinfo",
          "packer",
          "checkhealth",
          "help",
          "man",
          "gitcommit",
          "TelescopePrompt",
          "TelescopeResults",
        },
      },
      scope = { enabled = false },
    },
    cond = not_vscode
  },
  {
    "MattesGroeger/vim-bookmarks",
    init = function()
      vim.g.bookmark_no_default_key_mappings = 1
      vim.g.bookmark_save_per_working_dir = 1
      vim.g.bookmark_sign = ""
    end,
    config = function()
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
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    branch = '0.1.x',
    keys = {
      -- bookmarks
      {'<leader>sB', "<cmd>lua require('telescope').extensions.vim_bookmarks.all()<cr>", 'n', desc = "Show [b]ookmarks in workspace"},
      {'<leader>sb', "<cmd>lua require('telescope').extensions.vim_bookmarks.current_file()<cr>", 'n', desc = "Show [b]ookmarks in [b]uffer"},

      -- files
      {'<leader>sff', "<cmd>lua require('telescope').extensions.menufacture.find_files()<cr>", 'n', desc = 'Search [f]iles'},
      {'<leader>sfg', "<cmd>lua require('telescope').extensions.menufacture.git_files()<cr>", 'n', desc = 'search [g]it files'},
      {'<leader>sfr', "<cmd>lua require('telescope.builtin').oldfiles()<cr>", 'n', desc = 'Search [r]ecently opened files'},
      {'<leader>sfb', "<cmd>lua require('telescope.builtin').buffers()<cr>", 'n', desc = 'Search existing [b]uffers'},

      -- search
      {'<leader>sl', desc = 'Search with [l]ive grep'},
      {'<leader>sg', 'n', desc = 'Search with live grep on [g]it root'},
      {'<leader>sh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", 'n', desc = 'Search [h]elp'},
      {'<leader>sd', "<cmd>lua require('telescope.builtin').diagnostics()<cr>", 'n', desc = 'Search [d]iagnostics'},
      {'<leader>sr', "<cmd>lua require('telescope.builtin').resume()<cr>", 'n', desc = 'Search [r]esume'},
      {'<leader>ss', "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", '[s]ymbols in document'},
      {'<leader>sS', "<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<cr>", '[S]ymbols in workspace'},

      -- miscellaneous
      {'<leader>/', desc = 'Search for clipboard content'},
      {'<leader>?', mode = 'n', desc = '[?] search for word under cursor'},
      {'<leader>?', mode = 'v', desc = '[?] search for selection'},
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- extensions
      "natecraddock/telescope-zf-native.nvim",
      "molecule-man/telescope-menufacture",
      {
        "nvim-telescope/telescope-frecency.nvim",
        keys = {
          { "<leader>sfp", "<Cmd>lua require('telescope').extensions.frecency.frecency({ workspace = 'CWD' })<CR>", "n",
            noremap = true, silent = true, desc = "Telescope frecency" },
        },
        cond = not_vscode
      },
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        keys = {
          {"<leader>sa", "<Cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", "n", noremap = true, silent = true, desc = "[S]earch with ripgrep [a]rgs"},
        },
        cond = not_vscode
      },
    },
    config = function()
      require 'config_plugins.telescope'
      -- extensions
      require("telescope").load_extension("zf-native")
      require("telescope").load_extension("frecency")
      require('telescope').load_extension('menufacture')
      require("telescope").load_extension("live_grep_args")
    end,
    cond = not_vscode
  },
  {'farmergreg/vim-lastplace', cond = not_vscode},
  {
    'karb94/neoscroll.nvim',
    opts = {
      pre_hook = function()
        vim.opt.eventignore:append({
          'WinScrolled',
          'CursorMoved',
        })
      end,
      post_hook = function()
        vim.opt.eventignore:remove({
          'WinScrolled',
          'CursorMoved',
        })
      end,
      easing_function = "sine"
    },
    cond = not_vscode
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {},
    cond = not_vscode
  },
  {
    'williamboman/mason.nvim',
    build = function() pcall(vim.cmd, 'MasonUpdate') end,
    cond = not_vscode
  },
  {
    'VonHeikemen/lsp-zero.nvim', branch = 'v3.x',
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
      {'hrsh7th/cmp-cmdline'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},

      -- Added by me
      {'ray-x/lsp_signature.nvim', opts = { toggle_key = '<C-h>', select_signature_key = '<A-n>' } },
      {'jay-babu/mason-null-ls.nvim'},
    },
    cond = not_vscode
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        css = { "prettierd" },
        html = { "prettierd" },
        javascript = { "prettierd" },
        json = { "prettierd" },
        markdown = { "prettierd" },
        python = { "ruff_fix", "isort", "black" },
        typescript = { "prettierd" },
        yaml = { "prettierd" },
      },
    },
    config = function(_, opts)
      local conform = require('conform')
      conform.setup(opts)
      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ async = true, lsp_fallback = true, range = range })
      end, { range = true })
      vim.keymap.set('v', '=', function()
          require("conform").format({async = true, lsp_fallback = true })
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, true, true), "n", false)
          return '<Ignore>'
      end, {expr = true})
      vim.keymap.set("n", "==", function()
        conform.format({
          range = {
            ["start"] = vim.api.nvim_win_get_cursor(0),
            ["end"] = vim.api.nvim_win_get_cursor(0),
          }, async = true, lsp_fallback = true
        })
        return '<Ignore>'
      end, {expr = true})
      vim.keymap.set("n", "<F3>", function()
        conform.format({ async = true, lsp_fallback = true })
      end, { desc = "Run [b]uffer [f]ormatting" })
      vim.keymap.set("n", "<leader>bf", function()
        conform.format({ async = true, lsp_fallback = true })
      end, { desc = "Run [b]uffer [f]ormatting" })
    end,
    cond = not_vscode
  },
  {
    'Bekaboo/dropbar.nvim',
    opts = {
      general = {
        enable = function(buf, win, _)
          return not vim.api.nvim_win_get_config(win).zindex
              and (vim.bo[buf].buftype == '' or vim.bo[buf].buftype == 'acwrite' or vim.bo[buf].buftype == 'nowrite' or vim.bo[buf].buftype == 'terminal')
              and vim.api.nvim_buf_get_name(buf) ~= ''
              and not vim.wo[win].diff
        end,
      },
      bar = {
        sources = function(buf, _)
          local sources = require('dropbar.sources')
          local utils = require('dropbar.utils')
          if vim.bo[buf].ft == 'markdown' then
            return {
              utils.source.fallback({
                sources.treesitter,
                sources.markdown,
                sources.lsp,
              }),
            }
          end
          if vim.bo[buf].buftype == 'terminal' then
            return {
              sources.terminal,
            }
          end
          return {
            utils.source.fallback({
              sources.lsp,
              sources.treesitter,
            }),
          }
        end,
      },
      icons = {
        ui = {
          bar = {
            separator = ' > ',
          },
          menu = {
            indicator = ' > ',
          },
        },
        kinds = {
          symbols = {
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
          }
        }
      }
    },
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
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = {'DiffviewOpen', 'DiffviewFileHistory'},
    config = function()
      local actions = require("diffview.actions")
      require('diffview').setup(
        {
          hooks = {
            -- from :h diffview-config-hooks
            diff_buf_read = function(_)
              -- Change local options in diff buffers
              vim.opt_local.wrap = false -- wrapping causes hunk misalignment
              require('gitsigns').reset_base()
            end,
          },
          keymaps = {
            file_panel = {
              { "n", "s", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
              { "n", "u", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
              { "n", "-", false},
              { "n", "gf", function() actions.goto_file_edit(); vim.cmd('tabclose #') end, { desc = "Open the file in the previous tabpage and close diffview" } },
              { "n", "gF", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
              { "n", "<C-w>gf", function() actions.goto_file_tab(); vim.cmd('tabclose #') end, { desc = "Open the file in a new tabpage and close diffview" } },
              { "n", "<C-w>gF", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
              { "n", "<leader>b", false},
              { "n", "<leader><C-b>", actions.toggle_files, { desc = "Toggle the file panel" } },
            },
            file_history_panel = {
              { "n", "gf", function() actions.goto_file_edit(); vim.cmd('tabclose #') end, { desc = "Open the file in the previous tabpage and close diffview" } },
              { "n", "gF", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
              { "n", "<C-w>gf", function() actions.goto_file_tab(); vim.cmd('tabclose #') end, { desc = "Open the file in a new tabpage and close diffview" } },
              { "n", "<C-w>gF", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
              { "n", "<leader>b", false},
              { "n", "<leader><C-b>", actions.toggle_files, { desc = "Toggle the file panel" } },
            },
            view = {
              -- The `view` bindings are active in the diff buffers, only when the current
              -- tabpage is a Diffview.
              { "n", "gf", function() actions.goto_file_edit(); vim.cmd('tabclose #') end, { desc = "Open the file in the previous tabpage and close diffview" } },
              { "n", "gF", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
              { "n", "<C-w>gf", function() actions.goto_file_tab(); vim.cmd('tabclose #') end, { desc = "Open the file in a new tabpage and close diffview" } },
              { "n", "<C-w>gF", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
              { "n", "<leader>b", false},
              { "n", "<leader><C-b>", actions.toggle_files, { desc = "Toggle the file panel" } },
            }
          },
        })
    end,
    keys = {
      { "<leader>gd",  "<cmd>DiffviewOpen<cr>",                  desc = "[G]it [d]iff for repo", nowait = true },
      { "<leader>gD",  "<cmd>DiffviewOpen HEAD~<cr>",            desc = "[G]it [D]iff previous commit", nowait = true },
      { "<leader>gr", "<cmd>DiffviewFileHistory<cr>",            desc = "[G]it [r]epo history" },
      { "<leader>gf", "<cmd>DiffviewFileHistory --follow %<cr>", desc = "[G]it [f]ile history" },
      { "<leader>gm", function() vim.cmd("DiffviewOpen " .. (common.getGitMainBranch() or "")) end,            desc = "[G]it diff with [m]aster" },
      { "<leader>gl", "<cmd>.DiffviewFileHistory --follow<CR>",  desc = "[G]it file history for the current [l]ine"},
      { "<leader>gl", "<Esc><cmd>'<,'>DiffviewFileHistory --follow<CR>", mode = 'v',  desc = "[G]it file history for the visual se[l]ection"},
      { "<leader>gc", ":DiffviewOpen <C-R>+<CR>",                desc = "[G]it [c]ommit from clipboard", silent = true},
    },
    cond = not_vscode
  },
  {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
      local wk = require("which-key")
      wk.setup {
        plugins = { spelling = true },
      }
      wk.register({
        mode = { "n", "v" },
        ["<leader>w"] = { name = "+workspace"},
        ["<leader>e"] = { name = "+debug"},
        ["<leader>t"] = { name = "+toogle/tab"},
        ["<leader>o"] = { name = "+overseer/noice"},
        -- ["<leader>os"] = { name = "+noice"},
        ["<leader>s"] = { name = "+search" },
        ["<leader>sf"] = { name = "+go to file" },
        ["<leader>sb"] = { name = "+bookmarks" },
        ["<leader>g"] = { name = "+diffview"},
        ["<leader>h"] = { name = "+hunks"},
        ["<leader>b"] = { name = "+buffer/bookmarks"},
        ["<leader>x"] = { name = "+trouble"},
        ["<leader>v"] = { name = "+compare"},
      })
    end,
    cond = not_vscode
  },
  {
    'kevinhwang91/nvim-fundo',
    dependencies = 'kevinhwang91/promise-async',
    config = function()
      vim.opt.undofile = true
      require('fundo').setup({ limit_archives_size = 50 }) -- limit to store max 50 MB
    end,
    cond = not_vscode
  },
  {
    "mbbill/undotree",
    event = "VeryLazy",
    config = function()
      vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR><C-w>h<CR>")
    end,
    cond = not_vscode
  },
  {
    -- original author moved to another fork. consider https://github.com/zoriya/flake/blob/320bedb075a06a0d83b1f75d55933c63695f0ce5/modules/misc/nvim/lua/plugins/misc.lua#L3
    "Jendker/auto-save.nvim",
    cmd = 'ASToggle',
    keys = {
      { "<leader>ta", "<cmd>ASToggle<CR>", desc = "[T]oggle [a]utosave", silent = true },
    },
    config = function()
      vim.g.first_autosave_disable = 1
      vim.g.autosave_on = 0
      require("auto-save").setup {
        enabled = false,  -- this doesn't seem to work
        print_enabled = false,
        callbacks = {
          enabling = function() print "auto-save on"; vim.g.autosave_on = 1 end,
          disabling = function() if vim.g.first_autosave_disable == 1 then vim.g.first_autosave_disable = 0 else print "auto-save off"; vim.g.autosave_on = 0 end end,
          before_saving = function()
            common.disableAutoformat()
            vim.b.paste_start_mark = vim.fn.getpos("'[")
            vim.b.paste_end_mark = vim.fn.getpos("']")
          end,
          after_saving = function()
            if not vim.b.orbik_disable_autoformat then
              common.enableAutoformat()
            end
            vim.fn.setpos("'[", vim.b.paste_start_mark)
            vim.fn.setpos("']", vim.b.paste_end_mark)
          end,
        },
        condition = function(buf)
          local fn = vim.fn
          local utils = require("auto-save.utils.data")

          -- return true means will auto-save
          if fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {'oil'}) then
            return true
          end
          return false
        end,
      }
      vim.cmd('ASToggle') -- called manually because 'enabled = false' does not work
    end,
    cond = not_vscode
  },
  {
    'lewis6991/satellite.nvim',
    opts = {
      current_only = true,
      winblend = 0,
      handlers = {
        cursor = {
          enable = false,
        },
        diagnostic = {
          min_severity = vim.diagnostic.severity.ERROR,
        },
      },
    },
    cond = not_vscode
  },
  {"tpope/vim-sleuth", init = function() vim.g.sleuth_cpp_heuristics = 0 end, cond = not_vscode}, -- automatically detect tabwidth
  {
    -- from https://github.com/madmaxieee/nvim-config/blob/e6933861623375/lua/custom/autocmd/persistence.lua#L4
    "folke/persistence.nvim",
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath "state" .. "/sessions/"), -- directory where session files are saved
      options = vim.opt.sessionoptions:get(),    -- sessionoptions used for saving
      pre_save = function()
        local tabpages = vim.api.nvim_list_tabpages()
        for _, tabpage in ipairs(tabpages) do
          local windows = vim.api.nvim_tabpage_list_wins(tabpage)
          for _, window in ipairs(windows) do
            local buffer = vim.api.nvim_win_get_buf(window)
            local file_name = vim.api.nvim_buf_get_name(buffer)
            if string.find(file_name, "diffview:") then
              -- close all windows in this tab
              for _, this_window in ipairs(windows) do
                vim.api.nvim_win_close(this_window, false)
              end
              break
            end
            if string.find(file_name, "fugitive:") then
              -- close buffer
              vim.api.nvim_win_close(window, false)
            end
          end
        end
      end,
    },
    config = function(_, opts)
      require('persistence').setup(opts)
      local persistence_group = vim.api.nvim_create_augroup("Persistence", { clear = true })

      -- disable persistence for certain directories
      local home = vim.uv.os_homedir()
      local disabled_dirs = {
        [home] = true,
        [home .. "/Downloads"] = true,
        ["/private/tmp"] = true,
        ["/tmp"] = true,
      }

      vim.api.nvim_create_autocmd({ "VimEnter" }, {
        group = persistence_group,
        callback = function()
          local cwd = vim.fn.getcwd()
          if vim.fn.argc() == 0 and not vim.g.started_with_stdin and not disabled_dirs[cwd] then
            require("persistence").load()
          else
            require("persistence").stop()
          end
        end,
        nested = true,
      })

      -- disable persistence if nvim started with stdin
      vim.api.nvim_create_autocmd({ "StdinReadPre" }, {
        group = persistence_group,
        callback = function()
          vim.g.started_with_stdin = true
        end,
      })
    end,
    cond = not_vscode
  },
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = "VeryLazy",
    cond = not_vscode
  },
  {"iamcco/markdown-preview.nvim",
    -- build = function() vim.fn["mkdp#util#install"]() end,
    -- doing this until https://github.com/iamcco/markdown-preview.nvim/issues/50 works how it should
    -- if it still fails, run `:call mkdp#util#install()`
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_preview_options = { ["disable_sync_scroll"] = 0 }
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
    cond = not_vscode
  },
  {"wintermute-cell/gitignore.nvim", cmd = 'Gitignore', dependencies = { "nvim-telescope/telescope.nvim" }, cond = not_vscode},
  {
    -- config from https://www.lazyvim.org/plugins/editor#troublenvim
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true, action_keys = {toggle_fold = {"zA", "za", "h", "l"} } },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
      { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").previous({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
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
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
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
            ['l'] = actions.jump,
            ['h'] = actions.close_fold,
            ['<C-c>'] = actions.close,
            ['<C-n>'] = actions.next,
            ['<C-p>'] = actions.previous,
          },
        },
      })
    end,
    cond = not_vscode
  },
  {
    "kevinhwang91/nvim-bqf",
    event = "VeryLazy",
    opts = {},
    cond = not_vscode
  },
  {
    'stevearc/aerial.nvim',
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToogle", "AerialNavOpen", "AerialNext", "AerialPrev" },
    keys = {
      {'<leader>ba', '<cmd>AerialToggle<CR>', 'n', desc = "[b]uffer [a]erial toggle"},
      { "[s", function() require('aerial').prev() end, desc = "Previous aerial symbol", mode = { "n", "v" } },
      { "]s", function() require('aerial').next() end, desc = "Next aerial symbol", mode = { "n", "v" } },
      { "[u", function() require('aerial').prev_up() end, desc = "Previous aerial parent symbol", mode = { "n", "v" } },
      { "]u", function() require('aerial').next_up() end, desc = "Next aerial parent symbol", mode = { "n", "v" } },
    },
    opts = {
      layout = {
        max_width = { 80, 0.2 },
      },
      autojump = true,
      close_on_select = true,
      highlight_on_jump = 150,
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {buffer = bufnr})
        vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {buffer = bufnr})
      end
    },
    -- Optional dependencies
    dependencies = {
       "nvim-treesitter/nvim-treesitter",
       "nvim-tree/nvim-web-devicons"
    },
    cond = not_vscode
  },
  {
    'hedyhli/outline.nvim',
    cmd = { "Outline", "OutlineOpen" },
    keys = { {'<leader>bo', '<cmd>Outline<CR>', 'n', desc = "[b]uffer symbols [o]outline"} },
    opts = { outline_window = { auto_close = true, auto_goto = true, }, },
    cond = not_vscode,
  },
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
      filetypes_denylist = {
        "dirvish",
        "fugitive",
        "lazy",
        "Trouble",
        "Outline",
        "spectre_panel",
        "toggleterm",
        "TelescopePrompt",
        "oil",
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
    cond = not_vscode,
  },
  {
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
    keys = {
      { "<leader>R", function() require("spectre").open() end, desc = "[R]eplace in files (Spectre)" },
      { "<leader>R", '<esc><cmd>lua require("spectre").open_visual()<CR>', mode = 'v', desc = "[R]eplace selection (Spectre)" },
    },
    cond = not_vscode
  },
  {
    'xiyaowong/virtcolumn.nvim',
    config = function() vim.cmd("autocmd FileType python setlocal colorcolumn=88") end,
    cond = not_vscode
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", ':exe ":TodoTrouble cwd=" .. fnameescape(expand("%:p"))<cr>', desc = "Todo (Trouble) current file", silent = true },
      { "<leader>xT", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble) in workspace", silent = true },
      { "<leader>st", ':exe ":TodoTelescope cwd=" .. fnameescape(expand("%:p"))<cr>', desc = "Todo current file", silent = true },
      { "<leader>sT", "<cmd>TodoTelescope<cr>", desc = "Todo in workspace", silent = true },
    },
    opts = {
      highlight = {
        multiline = false, -- rarely useful
        pattern = [[.*<(KEYWORDS)\s*(\s|:)]],
        keyword = "fg", -- make it less flashy
      },
      search = {
        pattern = [[\b(KEYWORDS)(\s|:)]],
      }
    },
    cond = not_vscode
  },
  -- {
  --   'm4xshen/hardtime.nvim',
  --   opts = {
  --     disabled_keys = {
  --       ["<Left>"] = { "n", "x" },
  --       ["<Right>"] = { "n", "x" },
  --       ["<Up>"] = {},
  --       ["<Down>"] = {},
  --     },
  --     restricted_keys = { ["j"] = {}, ["k"] = {}, ["<C-N>"] = {}, ["<C-P>"] = {} },
  --     disable_mouse = false,
  --   },
  --   cond = not_vscode,
  -- },
  {
    'Jendker/nvim-lint',
    commit = 'ddd8c70',
    event = 'VeryLazy',
    opts = {
      linters_by_ft = {
        json = {'jsonlint'},
      },
    },
    config = function(_, opts)
      -- some code from https://github.com/stevearc/dotfiles/blob/2fcdaf586372a9809d3015c0cd58675a53fe0b48/.config/nvim/lua/plugins/lint.lua#L32
      local lint = require('lint')
      vim.g.try_lint = function(args)
        args = args or {}
        lint.try_lint(nil, args)
        if vim.g.codespell_active then
          lint.try_lint("codespell", {ignore_errors = true})
        end
      end
      vim.g.codespell_active = true -- enabled by default
      lint.linters_by_ft = opts.linters_by_ft
      local timer = assert(vim.uv.new_timer())
      local DEBOUNCE_MS = 500
      local aug = vim.api.nvim_create_augroup("Lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
        group = aug,
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          timer:stop()
          timer:start(
            DEBOUNCE_MS,
            0,
            vim.schedule_wrap(function()
              if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].modifiable then
                vim.api.nvim_buf_call(bufnr, function()
                  vim.g.try_lint()
                end)
              end
            end)
          )
        end,
      })
      vim.g.try_lint({ ignore_errors = true })
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<leader>ts', function()
        vim.g.codespell_active = not vim.g.codespell_active
        if vim.g.codespell_active then
          vim.notify("Enabled codespell", vim.log.levels.INFO)
          vim.g.try_lint()
        else
          vim.notify("Disabled codespell", vim.log.levels.INFO)
          vim.diagnostic.reset(nil, 0)
        end
      end, {desc = "[T]oggle code[s]pell"})
    end,
    cond = not_vscode
  },
  {
    'NvChad/nvim-colorizer.lua',
    opts = {
      user_default_options = {
        RGB   = false, -- #RGB hex codes
        names = false, -- "Name" codes like Blue or blue
      },
    },
    cond = not_vscode
  },
  {
    "stevearc/overseer.nvim",
    cmd = {
      "Grep",
      "Make",
      "OverseerDebugParser",
      "OverseerInfo",
      "OverseerOpen",
      "OverseerRun",
      "OverseerRunCmd",
      "OverseerToggle",
    },
    keys = {
      { "<leader>oo", "<cmd>OverseerToggle<CR>", mode = "n", desc = "OverseerToggle" },
      { "<leader>or", "<cmd>OverseerRun<CR>", mode = "n", desc = "OverseerRun" },
      { "<leader>oc", "<cmd>OverseerRunCmd<CR>", mode = "n", desc = "OverseerRunCmd" },
      { "<leader>ol", "<cmd>OverseerLoadBundle<CR>", mode = "n", desc = "OverseerLoadBundle" },
      { "<leader>ob", "<cmd>OverseerToggle! bottom<CR>", mode = "n", desc = "OverseerToggle" },
      { "<leader>od", "<cmd>OverseerQuickAction<CR>", mode = "n", desc = "OverseerQuickAction" },
      { "<leader>os", "<cmd>OverseerTaskAction<CR>", mode = "n", desc = "OverseerTaskAction" },
    },
    opts = {
      templates = { builtin = true },
      strategy = { "jobstart" },
      dap = false,
      log = {
        {
          type = "echo",
          level = vim.log.levels.WARN,
        },
        {
          type = "file",
          filename = "overseer.log",
          level = vim.log.levels.DEBUG,
        },
      },
      task_launcher = {
        bindings = {
          n = {
            ["<leader>c"] = "Cancel",
          },
        },
      },
      component_aliases = {
        default = {
          { "display_duration", detail_level = 2 },
          "on_output_summarize",
          "on_exit_set_status",
          { "on_complete_notify", system = "unfocused" },
          "on_complete_dispose",
        },
        default_neotest = {
          "unique",
          { "on_complete_notify", system = "unfocused", on_change = true },
          "default",
        },
      },
      post_setup = {},
    },
    config = function(_, opts)
      opts.templates = vim.tbl_keys(opts.templates)
      local overseer = require("overseer")
      overseer.setup(opts)
      for _, cb in pairs(opts.post_setup) do
        cb()
      end
      vim.api.nvim_create_user_command("OverseerDebugParser", 'lua require("overseer").debug_parser()', {})
      vim.api.nvim_create_user_command("Grep", function(params)
        local args = vim.fn.expandcmd(params.args)
        -- Insert args at the '$*' in the grepprg
        local cmd, num_subs = vim.o.grepprg:gsub("%$%*", args)
        if num_subs == 0 then
          cmd = cmd .. " " .. args
        end
        local cwd
        local has_oil, oil = pcall(require, "oil")
        if has_oil then
          cwd = oil.get_current_dir()
        end
        local task = overseer.new_task({
          cmd = cmd,
          cwd = cwd,
          name = "grep " .. args,
          components = {
            {
              "on_output_quickfix",
              errorformat = vim.o.grepformat,
              open = not params.bang,
              open_height = 8,
              items_only = true,
            },
            -- We don't care to keep this around as long as most tasks
            { "on_complete_dispose", timeout = 30 },
            "default",
          },
        })
        task:start()
      end, { nargs = "*", bang = true, bar = true, complete = "file" })

      vim.api.nvim_create_user_command("Make", function(params)
        -- Insert args at the '$*' in the makeprg
        local cmd, num_subs = vim.o.makeprg:gsub("%$%*", params.args)
        if num_subs == 0 then
          cmd = cmd .. " " .. params.args
        end
        local task = require("overseer").new_task({
          cmd = vim.fn.expandcmd(cmd),
          components = {
            { "on_output_quickfix", open = not params.bang, open_height = 8 },
            "unique",
            "default",
          },
        })
        task:start()
      end, {
        desc = "Run your makeprg as an Overseer task",
        nargs = "*",
        bang = true,
      })
    end,
    cond = not_vscode
  },
  {
    -- Prettier vim.ui.select() and vim.ui.input()
    -- https://github.com/stevearc/dressing.nvim#configuration
    "stevearc/dressing.nvim",
    opts = {
      input = {
        -- messes up menufacture glob input
        enabled = false,
        -- win_options = {
        --   sidescrolloff = 4,
        -- },
        -- get_config = function()
        --   if vim.api.nvim_win_get_width(0) < 50 then
        --     return {
        --       relative = "editor",
        --     }
        --   end
        -- end,
      },
    },
    config = function(_, opts)
      require("dressing").setup(opts)
      vim.keymap.set("n", "z=", function()
        local word = vim.fn.expand("<cword>")
        local suggestions = vim.fn.spellsuggest(word)
        vim.ui.select(
          suggestions,
          {},
          vim.schedule_wrap(function(selected)
            if selected then
              vim.cmd.normal({ args = { "ciw" .. selected }, bang = true })
            end
          end)
        )
      end)
    end,
    init = function()
      -- Shim for vim.ui.open
      if vim.ui.open then
        return
      end

      ---Copied from vim.ui.open in Neovim 0.10+
      ---@param path string
      ---@return nil|string[] cmd
      ---@return nil|string error
      local function get_open_cmd(path)
        if vim.fn.has("mac") == 1 then
          return { "open", path }
        elseif vim.fn.has("win32") == 1 then
          if vim.fn.executable("rundll32") == 1 then
            return { "rundll32", "url.dll,FileProtocolHandler", path }
          else
            return nil, "rundll32 not found"
          end
        elseif vim.fn.executable("wslview") == 1 then
          return { "wslview", path }
        elseif vim.fn.executable("xdg-open") == 1 then
          return { "xdg-open", path }
        else
          return nil, "no handler found"
        end
      end

      vim.ui.open = function(path)
        local is_uri = path:match("%w+:")
        if not is_uri then
          path = vim.fn.expand(path)
        end
        local cmd, err = get_open_cmd(path)
        if not cmd or err then
          return nil, err
        end
        local jid = vim.fn.jobstart(cmd, { detach = true })
        if jid <= 0 then
          return nil, "Failed to start job"
        end
      end
    end,
    cond = not_vscode
  },
  {
    'stevearc/stickybuf.nvim',
    cmd = { "PinBuffer", "PinBuftype", "PinFiletype" },
    opts = {},
    cond = not_vscode
  },
  require('debugging'),
}

-- use the lazy_opts until this is fixed: https://github.com/rmagatti/auto-session/issues/223
local lazy_opts = {}

require("lazy").setup(plugins, lazy_opts)
