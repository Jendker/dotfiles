-- set up vscode-neovim helpers
function not_vscode()
  return vim.fn.exists('g:vscode') == 0
end

vscode = vim.fn.exists('g:vscode') ~= 0

function GetGitMainBranch()
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

