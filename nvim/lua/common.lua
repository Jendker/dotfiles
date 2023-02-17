-- set up vscode-neovim helpers
not_vscode = function()
  return vim.fn.exists('g:vscode') == 0
end
vscode = vim.fn.exists('g:vscode') ~= 0
-- for keymaps
map = function(mode, key, action, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, key, action, options)
end
