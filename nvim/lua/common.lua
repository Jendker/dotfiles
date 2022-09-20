-- set up vscode-neovim helpers
nocode = function()
  return vim.fn.exists('g:vscode') == 0
end
