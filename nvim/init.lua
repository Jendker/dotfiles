-- Speed up by caching
pcall(require, 'impatient')
-- Global functions
require "globals"
-- Sensible defaults
require "settings"
-- Install plugins
require "plugins"
-- Plugin settings
require "plugin_settings"
-- Key mappings
require "keymaps"
