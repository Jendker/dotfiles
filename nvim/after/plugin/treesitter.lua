require('nvim-treesitter.configs').setup({
  ensure_installed = { "cpp", "python", "bash", "html", "json", "yaml",
    "markdown", "markdown_inline", "lua", "vim", "help", "regex"},
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
        ["aw"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
        ["ai"] = { query = "@conditional.outer" },
        ["ii"] = { query = "@conditional.inner" },
      },
      include_surrounding_whitespace = true,
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
        [']o'] = "@loop.*",
        [']w'] = { query = "@scope", query_group = "locals", desc = "Next scope start" },
        [']z'] = { query = "@fold", query_group = "folds", desc = "Next fold start" },
        [']i'] = "@conditional.outer",
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
        [']O'] = "@loop.*",
        [']W'] = { query = "@scope", query_group = "locals", desc = "Next scope end" },
        [']Z'] = { query = "@fold", query_group = "folds", desc = "Next fold end" },
        [']I'] = "@conditional.outer",
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
        ['[o'] = "@loop.*",
        ['[w'] = { query = "@scope", query_group = "locals", desc = "Previous scope start" },
        ['[z'] = { query = "@fold", query_group = "folds", desc = "Previous fold start" },
        ['[i'] = "@conditional.outer",
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
        ['[O'] = "@loop.*",
        ['[W'] = { query = "@scope", query_group = "locals", desc = "Previous scope end" },
        ['[Z'] = { query = "@fold", query_group = "folds", desc = "Previous fold end" },
        ['[I'] = "@conditional.outer",
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
      init_selection = "<A-w>",
      node_incremental = "<A-w>",
      node_decremental = "<bs>",
    },
  },
  highlight = {
    enable = not vscode,
  },
})
require'treesitter-context'.setup{
  enable = not vscode
}
