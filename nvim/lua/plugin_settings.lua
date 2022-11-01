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
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
  highlight = {
    enable = nocode(),
  },
})
vim.api.nvim_create_autocmd("FileType", {pattern = "cpp" , command = "setlocal commentstring=//\\ %s"})
