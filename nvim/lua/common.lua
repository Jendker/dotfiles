-- set up vscode-neovim helpers
function not_vscode()
  return vim.fn.exists('g:vscode') == 0
end

vscode = vim.fn.exists('g:vscode') ~= 0

function TableToString(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. TableToString(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local M = {}

function M.getGitMainBranch()
  -- get git main branch name
  local get_main_branch_shell_command = [[command git rev-parse --git-dir &>/dev/null || return
    local ref
    for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk}; do
      if command git show-ref -q --verify $ref; then
        echo ${ref:t}
        return
      fi
    done
    echo master
  ]]
  local is_git_repo = string.gsub(vim.fn.system('git rev-parse --is-inside-work-tree'), "\n$", "")
  if is_git_repo == "true" then
    return string.gsub(vim.fn.system(get_main_branch_shell_command), "\n$", "")
  else
    return nil
  end
end

function M.getVisualSelection()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', {})
  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ''
  end
end

function M.bufferEmpty(buffer)
  return vim.api.nvim_buf_line_count(buffer) == 1 and vim.api.nvim_buf_get_lines(buffer, 0, 1, {true})[1] == ""
end

function M.shallowCopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else   -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function M.enableAutoformat()
  vim.b.lsp_zero_enable_autoformat = true
  -- conform.nvim
  vim.b.disable_autoformat = false
end

function M.disableAutoformat()
  vim.b.lsp_zero_enable_autoformat = false
  -- conform.nvim
  vim.b.disable_autoformat = true
end

M.fileExists = function(dir, file_pattern)
  local contains = function(tbl, str)
    for _, v in ipairs(tbl) do
      if v == str then
        return true
      end
    end
    return false
  end
  local scan = require "plenary.scandir"
  local dirs = scan.scan_dir(dir, { depth = 1, search_pattern = file_pattern })
  return contains(dirs, dir .. "/" .. file_pattern)
end

return M
