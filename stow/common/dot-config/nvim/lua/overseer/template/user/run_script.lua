return {
  name = "run script",
  builder = function()
    local file = vim.fn.expand("%:p")
    local filetype_cmds = {
      go = { "go", "run" },
      python = { "python" },
      sh = { "bash" },
    }

    local filetype = vim.bo.filetype
    local cmd = filetype_cmds[filetype]

    if cmd then
      table.insert(cmd, file)
    else
      vim.notify("Oversser template - Unsupported filetype: " .. filetype)
    end
    return {
      cmd = cmd,
      components = {
        { "on_output_quickfix", set_diagnostics = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = {
    filetype = { "sh", "python", "go" },
  },
}
