require('nvim-treesitter.configs').setup({
  ensure_installed = { "cpp", "python", "bash", "html", "json", "yaml",
    "markdown", "markdown_inline", "lua", "vim", "vimdoc", "regex"},
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
      },
      include_surrounding_whitespace = true,
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
  },
  rainbow = {
    enable = not vscode,
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
  },
  matchup = {
    enable = true,
    disable_virtual_text = vscode,
  },
})
