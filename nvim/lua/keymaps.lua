require "common"

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format)
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])
vim.keymap.set({"n", "v"}, "<leader>D", [["_D]])
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- don't enter command history
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "q:", "<nop>")
vim.keymap.set("n", "q/", "<nop>")
vim.keymap.set("n", "q?", "<nop>")

-- new line with enter
vim.keymap.set('n', '<CR>', 'o<Esc>')
vim.keymap.set('n', '<S-CR>', 'O<Esc>')

-- select last pasted text
vim.keymap.set('n', 'gV', '`[v`]')

if vscode then
  vim.keymap.set('n', '?', "<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>")
  -- Get folding working with vscode neovim plugin
  vim.keymap.set('n', 'zM', ":call VSCodeNotify('editor.foldAll')<CR>")
  vim.keymap.set('n', 'zR', ":call VSCodeNotify('editor.unfoldAll')<CR>")
  vim.keymap.set('n', 'zc', ":call VSCodeNotify('editor.fold')<CR>")
  vim.keymap.set('n', 'zC', ":call VSCodeNotify('editor.foldRecursively')<CR>")
  vim.keymap.set('n', 'zo', ":call VSCodeNotify('editor.unfold')<CR>")
  vim.keymap.set('n', 'zO', ":call VSCodeNotify('editor.unfoldRecursively')<CR>")
  vim.keymap.set('n', 'za', ":call VSCodeNotify('editor.toggleFold')<CR>")
  local function moveCursor(direction)
    if (vim.fn.reg_recording() == '' and vim.fn.reg_executing() == '') then
      return ('g' .. direction)
    else
      return direction
    end
  end
  vim.keymap.set('n', 'k', function() return moveCursor('k') end, { expr = true, remap = true })
  vim.keymap.set('n', 'j', function() return moveCursor('j') end, { expr = true, remap = true })
  -- end folds helpers. Comes from https://github.com/vscode-neovim/vscode-neovim/issues/58#issuecomment-989481648
  -- and https://github.com/vscode-neovim/vscode-neovim/issues/58#issuecomment-1053940452
  vim.keymap.set("n", "<leader>c", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI]], { desc = 'Find and [C]hange word under cursor'})
else
  -- telescope
  vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [f]iles' })
  vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [g]rep' })
  vim.keymap.set('n', '<leader>si', require('telescope.builtin').git_files, { desc = '[S]earch in g[i]t files'})
  vim.keymap.set('n', '<leader>sr', function() require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") }) end, { desc = "[S]earch by g[r]ep with string"})
  vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch existing [b]uffers'})
  vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [h]elp' })
  vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [d]iagnostics' })
  vim.keymap.set('n', '<leader>so', require('telescope.builtin').oldfiles, { desc = '[S]earch recently [o]pened files' })
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set('i', '<C-c>', "<Esc>")
  vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Find and [C]hange word under cursor'})

end
