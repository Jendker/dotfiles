require "common"

local function map(mode, key, action, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, key, action, options)
end
-- new line with enter
map('n', '<CR>', 'o<Esc>')
map('n', '<S-CR>', 'O<Esc>')

-- select last pasted text
map('n', 'gV', '`[v`]')

-- telescope
if nocode then
  map('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>")
  map('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
  map('n', '<leader>fs', "<cmd>lua require('telescope.builtin').git_files()<cr>")
  -- map('n', '<leader>fg', function() require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") }) end)
  map('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>")
  map('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")
  map('n', 'gf', "<cmd>lua vim.lsp.buf.declaration()<cr>")
else
  map('n', '?', "<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>")
end
vim.g.mapleader = " "
