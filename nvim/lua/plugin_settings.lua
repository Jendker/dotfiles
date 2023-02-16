require "common"

-- clever-f
vim.g.clever_f_smart_case = 1
-- leap.nvim
require('leap').set_default_keymaps()
require('leap').opts.safe_labels = {}
require('nvim-treesitter.configs').setup({
  ensure_installed = { "cpp", "python", "bash", "json", "yaml", "markdown", "lua", "vim"},
  sync_install = true,
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
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
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
  highlight = {
    enable = not vscode,
  },
})
require'treesitter-context'.setup{
  enable = not vscode
}
-- Reserve space for diagnostic icons for plugins which need it
vim.opt.signcolumn = 'yes'
-- Comment c, cpp, cs, java with //
vim.api.nvim_command([[autocmd FileType c,cpp,cs,java setlocal commentstring=//\ %s]])
