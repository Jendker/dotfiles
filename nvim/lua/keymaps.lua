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

if vim.g.vscode == 1 then
  map('n', '?', "<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>")
end

-- telescope
if nocode then
  map('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>")
  map('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
  map('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>")
  map('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")
end
