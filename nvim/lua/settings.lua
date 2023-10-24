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
vim.opt.smartindent = false

-- Highlight line number without higlighting the whole line
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- Miscellaneous
vim.opt.wrap = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 4
vim.opt.termguicolors = true
vim.opt.laststatus = 3 -- global statusline
vim.o.updatetime = 200 -- CursorHold time default is 4s. Way too long

-- don't continue comment on newline
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")

vim.g.mapleader = " "

-- nicer diff markings
vim.opt.fillchars = vim.opt.fillchars + 'diff:╱'

vim.opt.spelllang = 'en_us'

local function augroup(name)
  return vim.api.nvim_create_augroup("jorbik_" .. name, { clear = true })
end
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})
-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})
-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown", "rst" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
-- file associations
vim.cmd([[
  augroup FileAssociations
    autocmd!
    autocmd BufRead,BufNewFile *.launch set filetype=xml
  augroup end
]])
-- lsp config
vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile"}, {
  group = augroup("misc_aucmds"),
  callback = function()
    require 'config_plugins.lsp-zero'
  end,
  once = true,
})

-- improve file reloads
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
-- vim.api.nvim_create_autocmd("FocusGained", {
  desc = "Reload files from disk when we focus vim",
  group = augroup("checktime_focus"),
  command = "if getcmdwintype() == '' | checktime | endif",
})
vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Every time we enter an unmodified buffer, check if it changed on disk",
  group = augroup("checktime_enter"),
  command = "if &buftype == '' && !&modified && expand('%') != '' | exec 'checktime ' . expand('<abuf>') | endif",
})
