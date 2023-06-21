require('common')
local telescope = require('telescope')
local actions = require('telescope.actions')
local trouble = require("trouble.providers.telescope")
local custom_pickers = require('config_plugins.telescope_custom_pickers')
telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<c-t>"] = trouble.open_with_trouble,
      },
      n = {
        ["<c-t>"] = trouble.open_with_trouble,
        ["q"] = function(...)
          return actions.close(...)
        end,
      },
    },
    layout_config = {
      horizontal = {
        width = 0.95,
        preview_width = 0.5,
      }
    },
  },
  pickers = {
    live_grep = {
      mappings = {
        i = {
          ["<C-Down>"] = function(...)
            return actions.cycle_history_next(...)
          end,
          ["<C-Up>"] = function(...)
            return actions.cycle_history_prev(...)
          end,
          ["<C-f>"] = function(...)
            return actions.preview_scrolling_down(...)
          end,
          ["<C-b>"] = function(...)
            return actions.preview_scrolling_up(...)
          end,
          ["<c-r>"] = actions.to_fuzzy_refine,
          ["<c-e>"] = custom_pickers.actions.set_extension,
          ["<c-l>"] = custom_pickers.actions.set_folders,
          ["<c-o>"] = custom_pickers.actions.set_glob,
          ["<c-g>"] = custom_pickers.actions.set_regex,
          ["<a-r>"] = custom_pickers.actions.reset_filters,
        },
      },
      additional_args = custom_pickers.default_additional_args,
    },
    buffers = {
      mappings = {
        i = { ["<c-q>"] = actions.delete_buffer },
        n = { ["<c-q>"] = actions.delete_buffer },
      },
    },
    find_files = {
      mappings = {
        i = { ["<c-o>"] =  function()
            local selection = require('telescope.actions.state').get_selected_entry()
            vim.fn.jobstart("xdg-open " .. selection.path)
          end },
        n = { ["<c-o>"] =  function()
            local selection = require('telescope.actions.state').get_selected_entry()
            vim.fn.jobstart("xdg-open " .. selection.path)
          end },
      },
    },
  },
})
-- vim_booksmarks
telescope.load_extension('vim_bookmarks')
-- more keymaps
vim.keymap.set('n', '<leader>?', require('telescope.builtin').grep_string, { desc = '[?] search for word under cursor'})
vim.keymap.set('v', '<leader>?', function()
    require('telescope.builtin').grep_string({ search = GetVisualSelection() })
  end,
  { desc = '[?] search for selection' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Search in current buffer' })
vim.keymap.set('v', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
    default_text = GetVisualSelection(),
  })
end, { desc = '[/] Search for selection in current buffer' })
