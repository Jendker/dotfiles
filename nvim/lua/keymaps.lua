local common = require("common")

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
map("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = true })
map("n", "<leader>bq", "<cmd>bp <BAR> bd #<CR>", { desc = "Close buffer"})
map({"n", "v"}, "<leader>d", [["_d]])
map({"n", "v"}, "<leader>D", [["_D]])
map({"n", "v"}, "<leader>c", [["_c]])
map({"n", "v"}, "<leader>C", [["_C]])
map("n", "<leader>tq", "<cmd>tabclose<cr>", { desc = "[T]ab [q] close" })
map("n", "<leader>tc", "<cmd>tabnew<CR>", { desc = "[T]ab [n]ew"})
map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "[T]ab [c]reate"})

-- center after buffer movements
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- don't enter command history
map("n", "Q", "<nop>")
map("n", "q:", "<nop>")
map("n", "q/", "<nop>")
map("n", "q?", "<nop>")

-- don't break scrolling. If you need join, use gJ instead
map({"n", "x"}, "J", "j")

-- select last pasted text
map('n', 'gV', '`[v`]')

map("n", "<leader>bn", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- toggle settings
map("n", "<leader>ts", function() toggle("spell") end, { desc = "[T]oggle [s]pelling" })
map("n", "<leader>tw", function() toggle("wrap") end, { desc = "[T]oggle word [w]rap" })
map("n", "<leader>to", "<leader>ta<leader>tb", { desc = "[T]oggle development [o]ptions", remap = true})
if vim.fn.has("nvim-0.9.0") == 1 then
  map("n", "<leader>ti", vim.show_pos, { desc = "Inspect Pos" }) -- highlights under cursor
end

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- search for selected text
map('v', '/', "\"fy/<C-R>f<CR>", {silent = true})
map('v', '?', "\"fy?<C-R>f<CR>", {silent = true})

local function open_with_default(text)
  local command
  local system_name = vim.loop.os_uname().sysname
  if system_name == "Darwin" then
    command = "open"
  elseif system_name == "Linux" then
    command = "xdg-open"
  else
    vim.api.nvim_err_writeln("System not known: " .. system_name)
    return
  end
  vim.fn.jobstart(command .. " " .. text)
end
map('n', '<leader>o',  function() open_with_default(vim.fn.expand('<cWORD>')) end, { desc = "Open with default application" })
map('v', '<leader>o', function() open_with_default(common.getVisualSelection()) end, { desc = "Open with default application" })

if vscode then
  map('n', '<leader>?', "<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>")
  map('v', '<leader>?', "\"fy<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': eval('@f')})<CR>")
  -- Get folding working with vscode neovim plugin
  map('n', 'zM', ":call VSCodeNotify('editor.foldAll')<CR>")
  map('n', 'zR', ":call VSCodeNotify('editor.unfoldAll')<CR>")
  map('n', 'zc', ":call VSCodeNotify('editor.fold')<CR>")
  map('n', 'zC', ":call VSCodeNotify('editor.foldRecursively')<CR>")
  map('n', 'zo', ":call VSCodeNotify('editor.unfold')<CR>")
  map('n', 'zO', ":call VSCodeNotify('editor.unfoldRecursively')<CR>")
  map('n', 'za', ":call VSCodeNotify('editor.toggleFold')<CR>")
  -- Fix issues with undo https://github.com/vscode-neovim/vscode-neovim/issues/1192
  map('n', 'u', ":call VSCodeNotify('undo')<CR>")
  map('n', '<C-r>', ":call VSCodeNotify('redo')<CR>")
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
  map('n', "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI]], { desc = 'Find and [C]hange word under cursor'})
  map('n', "<leader>rc", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gcI]], { desc = 'Find and [C]hange word under cursor with confirmation'})
  map('v', "<leader>r", [["fy:%s/<C-r>f/<C-r>f/gI]], { desc = 'Find and [C]hange selected'})
  map('v', "<leader>rc", [["fy:%s/<C-r>f/<C-r>f/gcI]], { desc = 'Find and [C]hange selected with confirmation'})
  map({'n', 'x'}, "<leader>ca", ":call VSCodeNotify('editor.action.quickFix')<CR>")
  map({'n', 'x'}, 'go', ":call VSCodeNotify('editor.action.goToTypeDefinition')<CR>")
  map({'n', 'x'}, 'gl', ":call VSCodeNotify('editor.action.showHover')<CR>")
else
  map('i', '<C-c>', "<Esc>")
  map("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Find and Change word under cursor'})
  map("n", "<leader>rc", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gcI<Left><Left><Left>]], { desc = 'Find and Change word under cursor with confirmation'})
  map('v', "<leader>r", [["fy:%s/<C-r>f/<C-r>f/gI<Left><Left><Left>]], { desc = 'Find and Change selected'})
  map('v', "<leader>rc", [["fy:%s/<C-r>f/<C-r>f/gcI<Left><Left><Left>]], { desc = 'Find and Change selected with confirmation'})
  -- Move Lines - this messes up VSCode pasting for some reason. Leave it here or find some plugin to do the same better
  map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
  map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
  map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
  map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
  map("v", "<A-j>", ":m '>+1<cr>gv=gv", { silent = true, desc = "Move down" })
  map("v", "<A-k>", ":m '<-2<cr>gv=gv", { silent = true, desc = "Move up" })
end
