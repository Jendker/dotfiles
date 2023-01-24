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
if nocode() then
  map('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>")
  map('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
  map('n', '<leader>fs', "<cmd>lua require('telescope.builtin').git_files()<cr>")
  -- map('n', '<leader>fg', function() require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") }) end)
  map('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>")
  map('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")
  map('n', 'gf', "<cmd>lua vim.lsp.buf.declaration()<cr>")
else
  map('n', '?', "<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>")
  -- Get folding working with vscode neovim plugin
  map('n', 'zM', ":call VSCodeNotify('editor.foldAll')<CR>")
  map('n', 'zR', ":call VSCodeNotify('editor.unfoldAll')<CR>")
  map('n', 'zc', ":call VSCodeNotify('editor.fold')<CR>")
  map('n', 'zC', ":call VSCodeNotify('editor.foldRecursively')<CR>")
  map('n', 'zo', ":call VSCodeNotify('editor.unfold')<CR>")
  map('n', 'zO', ":call VSCodeNotify('editor.unfoldRecursively')<CR>")
  map('n', 'za', ":call VSCodeNotify('editor.toggleFold')<CR>")
  local function moveCursor(direction)
    if (vim.fn.reg_recording() == '' and vim.fn.reg_executing() == '') then
      return ('g' .. direction)
    else
      return direction
    end
  end
  map('n', 'k', function() return moveCursor('k') end, { expr = true, remap = true })
  map('n', 'j', function() return moveCursor('j') end, { expr = true, remap = true })
  -- end folds helpers. Comes from https://github.com/vscode-neovim/vscode-neovim/issues/58#issuecomment-989481648
  -- and https://github.com/vscode-neovim/vscode-neovim/issues/58#issuecomment-1053940452
end
vim.g.mapleader = " "
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
map("n", "<leader>f", vim.lsp.buf.format)

-- don't enter command history
map("n", "Q", "<nop>")
map("n", "q:", "<nop>")
map("n", "q/", "<nop>")
map("n", "q?", "<nop>")
