require "common"

local function map(mode, key, action, opts)
  local options = { noremap = true, silent = false }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, key, action, options)
end

local function toggle(option, silent, values)
  if values then
    if vim.opt_local[option]:get() == values[1] then
      vim.opt_local[option] = values[2]
    else
      vim.opt_local[option] = values[1]
    end
    return print("Set " .. option .. " to " .. vim.opt_local[option]:get(), { title = "Option" })
  end
  vim.opt_local[option] = not vim.opt_local[option]:get()
  if not silent then
    if vim.opt_local[option]:get() then
      print("Enabled " .. option, { title = "Option" })
    else
      print("Disabled " .. option, { title = "Option" })
    end
  end
end

vim.g.mapleader = " "
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
map("n", "<leader>bf", vim.lsp.buf.format, { desc = "Run [b]uffer [f]ormatting" })
map({"n", "v"}, "<leader>d", [["_d]])
map({"n", "v"}, "<leader>D", [["_D]])
map("n", "<leader>pv", vim.cmd.Ex)

-- don't enter command history
map("n", "Q", "<nop>")
map("n", "q:", "<nop>")
map("n", "q/", "<nop>")
map("n", "q?", "<nop>")

-- new line with enter
map('n', '<CR>', 'o<Esc>')
map('n', '<S-CR>', 'O<Esc>')

-- select last pasted text
map('n', 'gV', '`[v`]')

map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- toggle settings
map("n", "<leader>ts", function() toggle("spell") end, { desc = "Toggle Spelling" })
map("n", "<leader>tw", function() toggle("wrap") end, { desc = "Toggle Word Wrap" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  map("n", "<leader>ti", vim.show_pos, { desc = "Inspect Pos" })
end

-- Move Lines
map("n", "<C-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<C-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<C-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<C-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<C-j>", ":m '>+1<cr>gv=gv", { silent = true, desc = "Move down" })
map("v", "<C-k>", ":m '<-2<cr>gv=gv", { silent = true, desc = "Move up" })

if vscode then
  map('n', '<leader>?', "<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>")
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
  -- don't use for now - it breaks going up down
  -- map('n', 'k', function() return moveCursor('k') end, { expr = true, remap = true })
  -- map('n', 'j', function() return moveCursor('j') end, { expr = true, remap = true })
  -- end folds helpers. Comes from https://github.com/vscode-neovim/vscode-neovim/issues/58#issuecomment-989481648
  -- and https://github.com/vscode-neovim/vscode-neovim/issues/58#issuecomment-1053940452
  map("n", "<leader>c", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI]], { desc = 'Find and [C]hange word under cursor'})
  map({'n', 'x'}, 'go', ":call VSCodeNotify('editor.action.goToTypeDefinition')<CR>")
  map({'n', 'x'}, 'gl', ":call VSCodeNotify('editor.action.showHover')<CR>")
else
  -- telescope
  map('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [f]iles' })
  map('n', '<leader>sl', require('telescope.builtin').live_grep, { desc = '[S]earch with [l]ive grep' })
  map('n', '<leader>sg', function() require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") }) end, { desc = "[S]earch after [g]rep with string"})
  map('n', '<leader>si', require('telescope.builtin').git_files, { desc = '[S]earch in g[i]t files'})
  map('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch existing [b]uffers'})
  map('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [h]elp' })
  map('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [d]iagnostics' })
  map('n', '<leader>so', require('telescope.builtin').oldfiles, { desc = '[S]earch recently [o]pened files' })
  map('n', '<leader>?', require('telescope.builtin').grep_string, { desc = '[?] search for word under cursor'})
  map('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [r]esume'})
  map('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  map('i', '<C-c>', "<Esc>")
  map("n", "<leader>c", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Find and [C]hange word under cursor'})

end
