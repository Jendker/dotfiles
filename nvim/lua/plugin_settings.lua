require "common"

-- clever-f
vim.g.clever_f_smart_case = 1
-- leap.nvim
require('leap').set_default_keymaps()
require('leap').opts.safe_labels = {}
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
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
      include_surrounding_whitespace = true,
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@scopename.inner",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@scopename.inner",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@scopename.inner",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@scopename.inner",
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
    enable = nocode(),
  },
})
-- Reserve space for diagnostic icons for plugins which need it
vim.opt.signcolumn = 'yes'
