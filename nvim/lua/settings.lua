require "common"

-- Add luarocks to rtp
local home = vim.uv.os_homedir()
package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.1/?.lua;"

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
vim.opt.showcmd = false -- prevent flickering if j/k is being held
vim.opt.title = true -- turn on for tmux and terminal apps tab title

-- don't continue comment on newline
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")

vim.g.mapleader = " "

-- nicer markings
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  diff = "╱",
}

vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

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
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
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
-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.g.diagnostics_separate = false
-- Reserve space for diagnostic icons
if vim.g.diagnostics_separate then
  vim.opt.signcolumn = 'yes:3'
else
  vim.opt.signcolumn = 'yes'
end

-- statuscolumn stuff taken and adjusted from https://github.com/LazyVim/LazyVim/blob/7831fc94ca5989baf766c0bb6ad36a70838c3d5a/lua/lazyvim/util/ui.lua
-- Returns a list of regular and extmark signs sorted by priority (low to high)
---@return Sign[], Sign?, Sign[]
---@param buf number
---@param lnum number
local function get_signs(buf, lnum)
  -- Get regular signs
  ---@type Sign[]
  local signs_placed = vim.fn.sign_getplaced(buf, { group = "*", lnum = lnum })[1].signs
  local other_signs = {}
  local diagnostic_signs = {}
  local git_sign = nil
  for _, sign in pairs(signs_placed) do
    local ret = vim.fn.sign_getdefined(sign.name)[1]
    ret.priority = sign.priority
    if vim.g.diagnostics_separate and ret.name and ret.name:find("Diagnostic") then
      diagnostic_signs[#diagnostic_signs+1] = ret
    elseif ret.name and ret.name:find("GitSign") then
      git_sign = ret
    else
      other_signs[#other_signs+1] = ret
    end
  end

  -- Get extmark signs
  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" }
  )
  for _, extmark in pairs(extmarks) do
    other_signs[#other_signs + 1] = {
      name = extmark[4].sign_hl_group or "",
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    }
  end

  -- Sort by priority
  table.sort(other_signs, function(a, b)
    return (a.priority or 0) < (b.priority or 0)
  end)

  return diagnostic_signs, git_sign, other_signs
end

---@return Sign?
---@param buf number
---@param lnum number
local function get_mark(buf, lnum)
  local marks = vim.fn.getmarklist(buf)
  vim.list_extend(marks, vim.fn.getmarklist())
  for _, mark in ipairs(marks) do
    if mark.pos[1] == buf and mark.pos[2] == lnum and mark.mark:match("[a-zA-Z]") then
      return { text = mark.mark:sub(2), texthl = "DiagnosticHint" }
    end
  end
end

---@param sign? Sign
---@param len? number
local function icon(sign, len)
  sign = sign or {}
  len = len or 2
  local text = vim.fn.strcharpart(sign.text or "", 0, len) ---@type string
  text = text .. string.rep(" ", len - vim.fn.strchars(text))
  return sign.texthl and ("%#" .. sign.texthl .. "#" .. text .. "%*") or text
end

function Statuscolumn()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local is_file = vim.bo[buf].buftype == ""
  local show_signs = vim.wo[win].signcolumn ~= "no"

  local components = { "%C", "", "", "", "" } -- foldcolumn, other_signs, diagnostics, line no., git signs

  if show_signs then
    local left, right
    local diagnostic_signs, git_sign, other_signs = get_signs(buf, vim.v.lnum)
    right = git_sign
    left = other_signs[#other_signs]
    if vim.v.virtnum ~= 0 then
      left = nil
      right = nil
    end
    if next(diagnostic_signs) ~= nil then
      components[3] = icon(diagnostic_signs[1])
    end
    -- Left: mark or non-git sign
    components[2] = icon(get_mark(buf, vim.v.lnum) or left)
    -- Right: git sign (only if file)
    components[5] = is_file and icon(right) or ""
  end

  -- Numbers in Neovim are weird
  -- They show when either number or relativenumber is true
  local is_num = vim.wo[win].number
  local is_relnum = vim.wo[win].relativenumber
  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    if vim.v.relnum == 0 then
      components[4] = is_num and "%l" or "%r" -- the current line
    else
      components[4] = is_relnum and "%r" or "%l" -- other lines
    end
    components[4] = "%=" .. components[4] .. " " -- right align
  end

  return table.concat(components, "")
end

if vim.fn.has("nvim-0.9.0") == 1 then
  vim.opt.statuscolumn = [[%!v:lua.Statuscolumn()]]
end
---- end of statuscolumn stuff

-- folding
local skip_foldexpr = {} ---@type table<number,boolean>
local skip_check = assert(vim.loop.new_check())

-- TODO maybe make it a separate module, similarly like folke?
-- https://github.com/LazyVim/LazyVim/blob/68ff818a5bb7549f90b05e412b76fe448f605ffb/lua/lazyvim/util/ui.lua#L147
function Foldexpr()
  local buf = vim.api.nvim_get_current_buf()

  -- still in the same tick and no parser
  if skip_foldexpr[buf] then
    return "0"
  end

  -- don't use treesitter folds for non-file buffers
  if vim.bo[buf].buftype ~= "" then
    return "0"
  end

  -- as long as we don't have a filetype, don't bother
  -- checking if treesitter is available (it won't)
  if vim.bo[buf].filetype == "" then
    return "0"
  end

  local ok = pcall(vim.treesitter.get_parser, buf)

  if ok then
    return vim.treesitter.foldexpr()
  end

  -- no parser available, so mark it as skip
  -- in the next tick, all skip marks will be reset
  skip_foldexpr[buf] = true
  skip_check:start(function()
    skip_foldexpr = {}
    skip_check:stop()
  end)
  return "0"
end

-- use tree-sitter for folding. If needed to use normal folding, run :set foldmethod=syntax
vim.opt.foldmethod = "expr"
if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.foldexpr = "v:lua.Foldexpr()"
else
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
end
vim.opt.foldlevelstart = 99 -- don't fold by default
-- end folding
