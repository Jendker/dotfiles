-- Global functions
require "globals"
-- Sensible defaults
require "settings"
-- Key mappings
require "keymaps"

-- Install plugins
-- no need to load this immediately, since we have packer_compiled
vim.defer_fn(function()
  require "plugins"
end, 0)

-- Packer compiled
local packer_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(packer_path)) == 0 then
  vim.cmd [[runtime! packer/packer_compiled.lua]]
end

-- Plugin settings
-- (at some point when I add it) require "plugin_settings"
