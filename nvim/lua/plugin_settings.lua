require "common"

-- clever-f
vim.g.clever_f_smart_case = 1
-- leap.nvim
require('leap').set_default_keymaps()
require('nvim-treesitter.configs').setup({
  ensure_installed = { "cpp", "python", "bash", "json", "yaml", "markdown" },
  sync_install = true,
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["aC"] = "@class.outer",
        ["iC"] = "@class.inner",
      },
    },
  },
  highlight = {
    enable = nocode(),
  },
})
vim.g['vim_current_word#highlight_only_in_focused_window'] = 1
vim.g['vim_current_word#highlight_delay'] = 100
