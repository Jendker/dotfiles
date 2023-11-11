require('nvim-treesitter.configs').setup({
  ensure_installed = { "bash", "cmake", "cpp", "css", "dockerfile", "go",
    "html", "json", "latex", "lua", "markdown", "markdown_inline", "python",
    "regex", "rust", "typescript", "vim", "vimdoc", "yaml" },
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["ao"] = "@loop.outer",
        ["io"] = "@loop.inner",
      },
      include_surrounding_whitespace = true,
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
        ["]o"] = { query = { "@loop.outer" } },
        ["]i"] = "@conditional.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
        ["]O"] = { query = { "@loop.outer" } },
        ["]I"] = "@conditional.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
        ["[o"] = { query = { "@loop.outer" } },
        ["[i"] = "@conditional.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
        ["[O"] = { query = { "@loop.outer" } },
        ["[I"] = "@conditional.outer",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = ".",
      scope_incremental = ";",
      node_decremental = "<bs>",
    },
  },
  highlight = {
    enable = not vscode,
    disable = function(_, bufnr)
      return vim.api.nvim_buf_line_count(bufnr) > 50000
    end
  },
  indent = {
    enable = not vscode,
    disable = { 'python' },
  },
  matchup = {
    enable = true,
    disable_virtual_text = vscode,
  },
})

-- Repeat movement with ; and ,
-- vim way: ; goes to the direction you were moving.
local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move, {silent = true})
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite, {silent = true})
