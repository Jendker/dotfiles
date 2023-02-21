-- set up vscode-neovim helpers
not_vscode = function()
  return vim.fn.exists('g:vscode') == 0
end
vscode = vim.fn.exists('g:vscode') ~= 0
