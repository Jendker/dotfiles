require "common"

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Line Numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indent Settings
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = true

-- Prefer ripgrep if it exists
-- if fn.executable("rg") > 0 then
--   vim.o.grepprg = "rg --hidden --glob '!.git' --no-heading --smart-case --vimgrep --follow $*"
--   vim.opt.grepformat = vim.opt.grepformat ^ { "%f:%l:%c:%m" }
-- end

-- Highlight on yank
vim.cmd([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]])
