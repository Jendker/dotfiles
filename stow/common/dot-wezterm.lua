-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'OneHalfDark'
config.color_scheme = 'Dracula'

-- config.enable_tab_bar = false
config.window_background_opacity = 0.97
-- config.font = wezterm.font('Source Code Pro', { weight = 'Medium'})
-- config.font_size = 11.5
config.font = wezterm.font_with_fallback {
  'SFMono Nerd Font',
  'BerkeleyMonoTrial-Regular',
  {
    family = 'MonaspaceNeon-Regular',
    harfbuzz_features = { 'ss07', 'calt' },
  },
}
config.font_size = 11
if wezterm.target_triple == 'aarch64-apple-darwin' then
  config.window_close_confirmation = 'NeverPrompt'
  config.window_decorations = "RESIZE"
  local weight = "Medium"
  config.font_size = 12
  if wezterm.hostname() == "Jedrzejs-Mac-mini.local" then
    config.font_size = 13
    weight = "Bold"
  end
  config.font = wezterm.font {
    family = 'Monaco Nerd Font',
    harfbuzz_features = { 'ss07', 'calt', 'liga=0' },
    weight = weight,
  }
  config.native_macos_fullscreen_mode = true
else
  -- disable the window title bar
  config.window_decorations = "NONE"
  -- Spawn a zsh shell in login mode
  config.default_prog = { '/usr/bin/zsh', '-l' }
end
-- I don't care about missing glyphs
config.warn_about_missing_glyphs = false
-- Default keybindings for panes not needed, I use tmux
-- Get default key bindings with wezterm show-keys --lua
-- config.disable_default_key_bindings = true
local act = wezterm.action
-- Set the keybindings I actually need
config.keys = {
  -- { key = 'C',      mods = 'CTRL',       action = act.CopyTo 'Clipboard' },
  -- { key = 'C',      mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
  -- { key = 'P',      mods = 'CTRL',       action = act.ActivateCommandPalette },
  -- { key = 'P',      mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
  -- { key = 'Copy',   mods = 'NONE',       action = act.CopyTo 'Clipboard' },
  -- { key = 'Paste',  mods = 'NONE',       action = act.PasteFrom 'Clipboard' },
  -- { key = 'v',      mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
  -- { key = 'v',      mods = 'SUPER',      action = act.PasteFrom 'Clipboard' },
  -- { key = 'V',      mods = 'CTRL',       action = act.PasteFrom 'Clipboard' },
  -- { key = 'V',      mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
  -- { key = 'Insert', mods = 'SHIFT',      action = act.PasteFrom 'PrimarySelection' },
  -- { key = 'Insert', mods = 'CTRL',       action = act.CopyTo 'PrimarySelection' },
  -- { key = 'L',      mods = 'CTRL',       action = act.ShowDebugOverlay }, -- CTRL-SHIFT-l activates the debug overlay
  -- On mac make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  { key = "LeftArrow", mods = "OPT", action = act { SendString = "\x1bb" } },
  -- Make Option-Right equivalent to Alt-f; forward-word
  { key = "RightArrow", mods = "OPT", action = act { SendString = "\x1bf" } },
  {
    key = 'f',
    mods = 'CMD|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = "LeftArrow",
    mods = "CTRL|SHIFT",
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = "RightArrow",
    mods = "CTRL|SHIFT",
    action = wezterm.action.DisableDefaultAssignment,
  },
}
-- config.mouse_bindings = {
--   -- Change the default click behavior so that it only selects
--   -- text and doesn't open hyperlinks
--   {
--     event = { Up = { streak = 1, button = 'Left' } },
--     mods = 'NONE',
--     action = act.CompleteSelection 'ClipboardAndPrimarySelection',
--   },

--   -- and make CTRL-Click or CMD open hyperlinks
--   {
--     event = { Up = { streak = 1, button = 'Left' } },
--     mods = 'CTRL',
--     action = act.OpenLinkAtMouseCursor,
--   },
--   {
--     event = { Up = { streak = 1, button = 'Left' } },
--     mods = 'CMD',
--     action = act.OpenLinkAtMouseCursor,
--   },
-- }
config.enable_osc52_clipboard_reading = true

-- and finally, return the configuration to wezterm
return config
