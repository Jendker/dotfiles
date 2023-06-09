-- coming from https://github.com/JoosepAlviste/dotfiles/blob/master/config/nvim/lua/j/plugins/telescope_custom_pickers.lua
local Path = require 'plenary.path'
local action_set = require 'telescope.actions.set'
local action_state = require 'telescope.actions.state'
local transform_mod = require('telescope.actions.mt').transform_mod
local actions = require 'telescope.actions'
local conf = require('telescope.config').values
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local os_sep = Path.path.sep
local pickers = require 'telescope.pickers'
local scan = require 'plenary.scandir'

local M = {
  default_additional_args = {'--fixed-strings'}
}

local function shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

local function extend_array(target_array, src_array)
  for i = 1, #src_array do
    table.insert(target_array, src_array[i])
  end
  return target_array
end

-- Keeps track of the active extension, folders, glob for `live_grep`
local live_grep_data = {
  ---@type nil|string
  extension = nil,
  ---@type nil|string[]
  directories = nil,
  ---@type nil|string
  glob = nil,
  ---@type string[]
  args = shallow_copy(M.default_additional_args),
}

local function reset_live_grep_filters()
  live_grep_data.extension = nil
  live_grep_data.directories = nil
  live_grep_data.glob = nil
  live_grep_data.args = shallow_copy(M.default_additional_args)
end


-- Run `live_grep` with the active filters (extension and folders)
local function run_live_grep(current_input)
  local glob_array = {}
  if live_grep_data.extension then
    glob_array = extend_array(glob_array, { '--iglob', '*.' .. live_grep_data.extension})
  end
  if live_grep_data.glob then
    glob_array = extend_array(glob_array, { '--iglob', live_grep_data.glob})
  end
  require('telescope.builtin').live_grep {
    additional_args = extend_array(glob_array, live_grep_data.args),
    search_dirs = live_grep_data.directories,
    default_text = current_input,
  }
end

M.actions = transform_mod {
  -- Ask for a file extension and open a new `live_grep` filtering by it
  set_extension = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local current_input = action_state.get_current_line()

    vim.ui.input({ prompt = '*.' }, function(input)
      if input == nil then
        return
      end

      live_grep_data.extension = input

      actions._close(prompt_bufnr, current_picker.initial_mode == 'insert')
      run_live_grep(current_input)
    end)
  end,

  -- Ask for a glob and open a new `live_grep` filtering by it
  set_glob = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local current_input = action_state.get_current_line()

    vim.ui.input({ prompt = 'Glob > '}, function(input)
      if input == nil then
        return
      end

      live_grep_data.glob = input

      actions._close(prompt_bufnr, current_picker.initial_mode == 'insert')
      run_live_grep(current_input)
    end)
  end,

   -- Resets filters
  reset_filters = function()
    local current_input = action_state.get_current_line()

    reset_live_grep_filters()
    run_live_grep(current_input)
  end,

    -- sets regex flag
  set_regex = function()
    local current_input = action_state.get_current_line()
    table.insert(live_grep_data.args, '--no-fixed-strings')
    run_live_grep(current_input)
  end,

  -- Ask the user for a folder and olen a new `live_grep` filtering by it
  set_folders = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local current_input = action_state.get_current_line()

    local data = {}
    scan.scan_dir(vim.uv.cwd(), {
      hidden = false,
      only_dirs = true,
      respect_gitignore = true,
      on_insert = function(entry)
        table.insert(data, entry .. os_sep)
      end,
    })
    table.insert(data, 1, '.' .. os_sep)

    actions._close(prompt_bufnr, current_picker.initial_mode == 'insert')
    pickers.new({}, {
      prompt_title = 'Folders for Live Grep',
      finder = finders.new_table { results = data, entry_maker = make_entry.gen_from_file {} },
      previewer = conf.file_previewer {},
      sorter = conf.file_sorter {},
      attach_mappings = function(bufnr)
        action_set.select:replace(function()
          local this_picker = action_state.get_current_picker(bufnr)

          local dirs = {}
          local selections = this_picker:get_multi_selection()
          if vim.tbl_isempty(selections) then
            table.insert(dirs, action_state.get_selected_entry().value)
          else
            for _, selection in ipairs(selections) do
              table.insert(dirs, selection.value)
            end
          end
          live_grep_data.directories = dirs

          actions.close(bufnr)
          run_live_grep(current_input)
        end)
        return true
      end,
    }):find()
  end,
}

-- Small wrapper over `live_grep` to first reset our active filters
M.live_grep = function()
  reset_live_grep_filters()

  require('telescope.builtin').live_grep()
end


return M
