local common = require('common')
local telescope = require('telescope')
local actions = require('telescope.actions')
local trouble = require("trouble.providers.telescope")
telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-t>"] = trouble.open_with_trouble,
        ["<C-f>"] = function(...)
          return actions.preview_scrolling_down(...)
        end,
        ["<C-b>"] = function(...)
          return actions.preview_scrolling_up(...)
        end,
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
          ["<c-r>"] = actions.to_fuzzy_refine,
        },
      },
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
  extensions = {
    menufacture = {
      mappings = {
        main_menu = { [{ 'i', 'n' }] = '<C-e>' },
      },
    },
  },
})
-- vim_booksmarks
telescope.load_extension('vim_bookmarks')
-- more keymaps
vim.keymap.set('n', '<leader>?', require('telescope').extensions.menufacture.grep_string, { desc = '[?] search for word under cursor'})
vim.keymap.set('v', '<leader>?', function()
    require('telescope').extensions.menufacture.grep_string({ search = common.getVisualSelection() })
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
    default_text = common.getVisualSelection(),
  })
end, { desc = '[/] Search for selection in current buffer' })
