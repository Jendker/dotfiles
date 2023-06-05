local M = {}

M.setup = function()
  local scrollbar = require("scrollbar")
  local colors = require("onedark.colors")
  scrollbar.setup({
    hide_if_all_visible = true,
    handle = {
      color = colors.orange
    }
  })
end

return M
