return {
  name = "run script with args",
  params = {
    args = { type = "string", order = 1 },
  },
  builder = function(params)
    local file = vim.fn.expand("%:p")
    local cmd = table.concat({ vim.bo.filetype, file, params.args }, " ")
    if vim.bo.filetype == "go" then
      cmd = table.concat({ "go", "run", file, params.args }, " ")
    end
    vim.notify(cmd)
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
