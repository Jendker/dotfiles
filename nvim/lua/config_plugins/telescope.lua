local telescope = require('telescope')
local actions = require('telescope.actions')
local trouble = require("trouble.providers.telescope")
local custom_pickers = require('config_plugins.telescope_custom_pickers')
telescope.setup({
  defaults = {
    mappings = {
      i = { ["<c-t>"] = trouble.open_with_trouble },
      n = { ["<c-t>"] = trouble.open_with_trouble },
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
          ["<a-r>"] = custom_pickers.actions.reset_filters,
        },
        n = {
          ["q"] = function(...)
            return actions.close(...)
          end,
        },
      },
    },
    buffers = {
      mappings = {
        i = { ["<c-q>"] = actions.delete_buffer },
        n = { ["<c-q>"] = actions.delete_buffer },
      },
    },
  },
})
-- vim_booksmarks
telescope.load_extension('vim_bookmarks')
vim.keymap.set('n', '<leader>?', require('telescope.builtin').grep_string, { desc = '[?] search for word under cursor'})
vim.keymap.set('v', '<leader>?', function()
    local function getVisualSelection()
      vim.cmd('noau normal! "vy"')
      local text = vim.fn.getreg('v')
      vim.fn.setreg('v', {})
      text = string.gsub(text, "\n", "")
      if #text > 0 then
        return text
      else
        return ''
      end
    end
    local text = getVisualSelection()
    require('telescope.builtin').grep_string({ search = text })
  end,
  { desc = '[?] search for selection' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
