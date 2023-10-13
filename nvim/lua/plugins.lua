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
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          jump_labels = function(motion)
            -- never show jump labels by default
            -- return false
            -- Always show jump labels for ftFT
            return vim.v.count == 0 and motion:find("[ftFT]")
            -- Show jump labels for ftFT in operator-pending mode
            -- return vim.v.count == 0 and motion:find("[ftFT]") and vim.fn.mode(true):find("o")
          end,
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "o", "v" }, function() require("flash").jump({ search = { forward = true, wrap = false, multi_window = false } }) end, desc = "Forward flash" },
      { "S", mode = { "n", "o" }, function() require("flash").jump({ search = { forward = false, wrap = false, multi_window = false } }) end, desc = "Backwards flash" },
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
  {
    'andymass/vim-matchup',
    init = function()
      vim.g.matchup_motion_enabled = not vscode
      vim.g.matchup_matchparen_enabled = not vscode
    end
  }, -- better % on matching delimeters
  -- Re-enable after this is fixed https://github.com/HiPhish/nvim-ts-rainbow2/issues/49
  -- 'HiPhish/nvim-ts-rainbow2',  -- colored brackets
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
  {"romainl/vim-cool", event = 'BufReadPost'}, -- auto hide highlight after search
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
      vim.keymap.set("n", "<leader>hM", function()
          local main_branch_name = common.getGitMainBranch()
          if main_branch_name ~= nil then
            local keys_string = "<C-W>v<C-W>l<cmd>Gedit " .. main_branch_name .. ":%<cr>"
            local keys = vim.api.nvim_replace_termcodes(keys_string, true, false, true)
            vim.api.nvim_feedkeys(keys, 'm', false)
          else
            vim.api.nvim_err_writeln("Not git repository")
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
    config = function()
      require("oil").setup({default_file_explorer = false})
      vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
      vim.keymap.set("n", "<leader>pv", require("oil").open, { desc = "Open directory view" })
    end,
    cond = not_vscode
  },
  {
    'navarasu/onedark.nvim',
    lazy = false, -- make sure we load this during startup, that's main colorscheme
    priority = 100,
    config = function()
      local onedark = require('onedark')
      onedark.setup{
        transparent = true,
        toggle_style_list = { 'light', 'dark' }, -- List of styles to toggle between
        diagnostics = {
          undercurl = false,
        },
        highlights = {
          IlluminatedWordText = {bg = '$bg3'},
          IlluminatedWordRead = {bg = '$bg3'},
          IlluminatedWordWrite = {bg = '$bg3'},
          IblIndent = { fg = '$bg3', fmt = "nocombine" },
        }
      }
      onedark.load()
      vim.keymap.set('n', '<leader>tt', function()
        onedark.setup({transparent = not vim.g.onedark_config.transparent})
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
      -- specify lualine_x depending on existance of Noice plugin
      local lualine_x = {}
      local is_ok, noice = pcall(require, 'noice')
      if is_ok then
        table.insert(lualine_x,
          {
            noice.api.status.mode.get,
            cond = function()
              -- Don't show if status is e.g. -- INSERT -- or -- VISUAL LINE --
              return noice.api.status.mode.has() and noice.api.status.mode.get():find("^-- .+ --$") == nil
            end,
          })
      end
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
            local codeium_str = vim.fn['codeium#GetStatusString']()
            if codeium_str == "" then
              return ""
            elseif string.find(codeium_str, "/") then
              return "Codeium: " .. codeium_str
            -- elseif codeium_str == " * " then
            --   return "Codeium thinking..."
            -- elseif codeium_str == " 0 " then
            --   return "No suggestions"
            else
              return ""
            end
          end
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
      {'<leader>sg', "<cmd>lua require('telescope').extensions.menufacture.grep_string({ search = vim.fn.input('Grep > ') })<cr>", 'n', desc = "Search after [g]rep with string"},
      {'<leader>sh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", 'n', desc = 'Search [h]elp'},
      {'<leader>sd', "<cmd>lua require('telescope.builtin').diagnostics()<cr>", 'n', desc = 'Search [d]iagnostics'},
      {'<leader>so', "<cmd>lua require('telescope').extensions.menufacture.live_grep({grep_open_files=true})<cr>", 'n', desc = 'Search with live grep in [o]pen buffers'},
      {'<leader>sr', "<cmd>lua require('telescope.builtin').resume()<cr>", 'n', desc = 'Search [r]esume'},
      {'<leader>ss', "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", '[s]ymbols in document'},
      {'<leader>sS', "<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<cr>", '[S]ymbols in workspace'},

      -- miscellaneous
      {'<leader>/', desc = '[/] Fuzzily search in current buffer'},
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
    config = function()
      local easing_function = "sine"
      local neoscroll = require('neoscroll')
      neoscroll.setup({
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
        easing_function = easing_function
      })
      local mappings = {}
      mappings['zt']  = { 'zt', { '250', easing_function, "'no_scroll'" } }
      mappings['zb']  = { 'zb', { '250', easing_function, "'no_scroll'" } }
      mappings["<C-y>"] = { "scroll", { "-0.10", "false", "100", easing_function, "'no_scroll'" } }
      mappings["<C-e>"] = { "scroll", { "0.10", "false", "100", easing_function, "'no_scroll'" } }
      require('neoscroll.config').set_mappings(mappings)
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
        python = { "isort", "black" },
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
      -- python's black does not support range formatting
      vim.keymap.set('v', '=', function ()
        if vim.bo.filetype ~= "python" then
          require("conform").format({async = true, lsp_fallback = true })
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, true, true), "n", true)
          return '<Ignore>'
        else
          return '='
        end
      end, {expr = true})
      vim.keymap.set("n", "==", function()
        if vim.bo.filetype ~= "python" then
          conform.format({
            range = {
              ["start"] = vim.api.nvim_win_get_cursor(0),
              ["end"] = vim.api.nvim_win_get_cursor(0),
            }, async = true, lsp_fallback = true
          })
          return '<Ignore>'
        else
          return '=='
        end
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
      bar = {
        sources = function(_, _)
          local sources = require('dropbar.sources')
          return {
            {
              get_symbols = function(buf, win, cursor)
                if vim.bo[buf].ft == 'markdown' then
                  return sources.markdown.get_symbols(buf, win, cursor)
                end
                for _, source in ipairs({
                  sources.lsp,
                  sources.treesitter,
                }) do
                  local symbols = source.get_symbols(buf, win, cursor)
                  if not vim.tbl_isempty(symbols) then
                    return symbols
                  end
                end
                return {}
              end,
            },
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
              { "n", "<leader>h", actions.toggle_files, { desc = "Toggle the file panel" } },
            },
            file_history_panel = {
              { "n", "gf", function() actions.goto_file_edit(); vim.cmd('tabclose #') end, { desc = "Open the file in the previous tabpage and close diffview" } },
              { "n", "gF", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
              { "n", "<C-w>gf", function() actions.goto_file_tab(); vim.cmd('tabclose #') end, { desc = "Open the file in a new tabpage and close diffview" } },
              { "n", "<C-w>gF", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
              { "n", "<leader>b", false},
              { "n", "<leader>h", actions.toggle_files, { desc = "Toggle the file panel" } },
            },
            view = {
              -- The `view` bindings are active in the diff buffers, only when the current
              -- tabpage is a Diffview.
              { "n", "gf", function() actions.goto_file_edit(); vim.cmd('tabclose #') end, { desc = "Open the file in the previous tabpage and close diffview" } },
              { "n", "gF", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
              { "n", "<C-w>gf", function() actions.goto_file_tab(); vim.cmd('tabclose #') end, { desc = "Open the file in a new tabpage and close diffview" } },
              { "n", "<C-w>gF", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
              { "n", "<leader>b", false},
              { "n", "<leader>h", actions.toggle_files, { desc = "Toggle the file panel" } },
            }
          },
        })
    end,
    keys = {
      { "<leader>gd",  "<cmd>DiffviewOpen<cr>",                  desc = "[G]it [d]iff for repo", nowait = true },
      { "<leader>gD",  "<cmd>DiffviewOpen HEAD~<cr>",            desc = "[G]it [D]iff previous commit", nowait = true },
      { "<leader>gr", "<cmd>DiffviewFileHistory<cr>",            desc = "[G]it [r]epo history" },
      { "<leader>gf", "<cmd>DiffviewFileHistory --follow %<cr>", desc = "[G]it [f]ile history" },
      { "<leader>gm", "<cmd>DiffviewOpen master<cr>",            desc = "[G]it diff with [m]aster" },
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
        ["<leader>s"] = { name = "+search" },
        ["<leader>sf"] = { name = "+go to file" },
        ["<leader>sb"] = { name = "+bookmarks" },
        ["<leader>t"] = { name = "+toogle/tab"}
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
    "folke/noice.nvim",
    event = "VeryLazy",
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
          long_message_to_split = true, -- if long messages should be sent to a split
        },
        messages = {
          enabled = true,
          view_search = "mini",
        },
        views = {
          mini = {
            timeout = 2500
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
    "zoriya/auto-save.nvim",
    keys = {
      { "<leader>ta", ":ASToggle<CR>", desc = "[T]oggle [a]utosave", silent = true },
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
            vim.b.lsp_zero_enable_autoformat = false
            vim.b.disable_autoformat = true
            vim.g.disable_autoformat = true
            vim.b.paste_start_mark = vim.fn.getpos("'[")
            vim.b.paste_end_mark = vim.fn.getpos("']")
          end,
          after_saving = function()
            vim.b.lsp_zero_enable_autoformat = true
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
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
    "rmagatti/auto-session",
    init = function()
      vim.o.sessionoptions=vim.o.sessionoptions .. ",winpos,terminal,folds"
    end,
    opts = {
      pre_save_cmds =
      { function()
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
      end },
      post_restore_cmds =
      { function()
        -- close if buffer is empty and is not the last window
        local tabpages = vim.api.nvim_list_tabpages()
        for _, tabpage in ipairs(tabpages) do
          local windows = vim.api.nvim_tabpage_list_wins(tabpage)
          for _, window in ipairs(windows) do
            local buffer = vim.api.nvim_win_get_buf(window)
            if common.bufferEmpty(buffer) and #vim.api.nvim_list_wins() ~= 1 then
              vim.api.nvim_win_close(window, false)
            end
          end
        end
      end }
    },
    cond = not_vscode,
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
    'Exafunction/codeium.vim',
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      -- disable by default - enable manually in machine_settings.lua
      vim.g.codeium_enabled = false
      vim.g.codeium_disable_bindings = 1
    end,
    config = function()
      vim.keymap.set('i', '<a-]>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, desc = "Codeium next suggestion" })
      vim.keymap.set('i', '<a-[>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, desc = "Codeium previous suggestion"})
      vim.keymap.set('i', '<a-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, desc = "Codeium clear suggestion" })
      vim.keymap.set('i', '<a-Bslash>', function() return vim.fn['codeium#Complete']() end, { expr = true, desc = "Codeium trigger complete"})
      vim.keymap.set('i', '<a-a>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true, desc = "Codeium accept"})
    end,
    cond = not_vscode
  },
  {
    'tzachar/highlight-undo.nvim',
    config = true,
    cond = not_vscode
  },
  {
    'stevearc/aerial.nvim',
    keys = { {'<leader>ba', '<cmd>AerialToggle<CR>', 'n', desc = "[b]uffer [a]erial toggle"} },
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
    'simrat39/symbols-outline.nvim',
    keys = { {'<leader>bo', '<cmd>SymbolsOutline<CR>', 'n', desc = "[b]uffer symbols [o]outline"} },
    opts = { auto_close = true, },
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
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
    keys = {
      { "<leader>R", function() require("spectre").open() end, desc = "[R]eplace in files (Spectre)" },
      { "<leader>R", '<esc><cmd>lua require("spectre").open_visual()<CR>', mode = 'v', desc = "[R]eplace selection (Spectre)" },
    }
  },
  {
    'xiyaowong/virtcolumn.nvim',
    cond = not_vscode,
    config = function() vim.cmd("autocmd filetype python setlocal colorcolumn=88") end,
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", ':exe ":TodoTrouble cwd=" .. fnameescape(expand("%:p"))<cr>', desc = "Todo (Trouble) current file", silent = true },
      { "<leader>xT", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble) in workspace", silent = true },
      { "<leader>st", ':exe ":TodoTelescope cwd=" .. fnameescape(expand("%:p"))<cr>', desc = "Todo current file", silent = true },
      { "<leader>sT", "<cmd>TodoTelescope<cr>", desc = "Todo in workspace", silent = true },
    },
    opts = {},
    cond = not_vscode
  },
  {
    'm4xshen/hardtime.nvim',
    opts = {
      disabled_keys = {
        ["<Left>"] = { "n", "x" },
        ["<Right>"] = { "n", "x" },
        ["<Up>"] = {},
        ["<Down>"] = {},
      },
      restricted_keys = { ["j"] = {}, ["k"] = {}, ["<C-N>"] = {}, ["<C-P>"] = {} },
      disable_mouse = false,
    },
    cond = not_vscode,
  },
  {
    'kevinhwang91/nvim-ufo',
    event = "BufReadPost",
    dependencies = {'kevinhwang91/promise-async'},
    config = function()
      require('config_plugins.folds').setup()
      vim.opt.fillchars = vim.opt.fillchars + 'foldopen:,foldclose:'
    end,
    cond = not_vscode,
  },
  {
    'mfussenegger/nvim-lint',
    ft = {
      "json",
    },
    opts = {
      linters_by_ft = {
        json = {'jsonlint'},
      },
    },
    config = function(_, opts)
      -- some code from https://github.com/stevearc/dotfiles/blob/2fcdaf586372a9809d3015c0cd58675a53fe0b48/.config/nvim/lua/plugins/lint.lua#L32
      local lint = require('lint')
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
              if vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_call(bufnr, function()
                  lint.try_lint(nil, { ignore_errors = true })
                end)
              end
            end)
          )
        end,
      })
      lint.try_lint(nil, { ignore_errors = true })
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    end,
    cond = not_vscode
  },
  require('debugging'),
}

-- use the lazy_opts until this is fixed: https://github.com/rmagatti/auto-session/issues/223
local lazy_opts = {
  install = {
    -- don't install missing plugins on startup as a workaround to auto-session issues with lazy
    missing = false,
  },
}

require("lazy").setup(plugins, lazy_opts)
