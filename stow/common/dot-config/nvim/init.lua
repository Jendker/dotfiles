-- Sensible defaults
require "settings"
-- Install plugins
require "plugins"
-- Key mappings
require "keymaps"
-- Machine specific settings
pcall(require, "machine_settings")
