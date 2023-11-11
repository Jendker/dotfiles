local common = require('common')
local telescope = require('telescope')
local actions = require('telescope.actions')
local trouble = require("trouble.providers.telescope")

local grep_string_default_additional_args = {'-w', '--case-sensitive'}

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
      additional_args = {'--fixed-strings'},
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
    grep_string = {
      additional_args = grep_string_default_additional_args
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

local grep_string_menu =
  require('telescope').extensions.menufacture.add_menu_with_default_mapping(
    require('telescope.builtin').grep_string,
    vim.tbl_extend('force', require('telescope').extensions.menufacture.grep_string_menu, {
      ['change glob_pattern'] = function(opts, callback)
        local glob_value = vim.fn.input("Glob pattern: ")
        local new_additional_args = common.shallowCopy(grep_string_default_additional_args)
        table.insert(new_additional_args, '--glob')
        table.insert(new_additional_args, glob_value)
        opts['additional_args'] = new_additional_args
        callback(opts)
      end,
    })
  )

-- vim_booksmarks
telescope.load_extension('vim_bookmarks')
-- more keymaps
vim.keymap.set('n', '<leader>?', grep_string_menu, { desc = '[?] search for word under cursor'})
vim.keymap.set('v', '<leader>?', function()
    grep_string_menu({ search = common.getVisualSelection() })
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
vim.keymap.set('n', '<leader>sl',
  require('telescope').extensions.menufacture.add_menu_with_default_mapping(
    require('telescope.builtin').live_grep,
    vim.tbl_extend('force', require('telescope').extensions.menufacture.live_grep_menu, {
      ['toggle use_regex'] = function(opts, callback)
        local flag_key = 'additional_args'
        local flag_value = "--fixed-strings"
        require('telescope').extensions.menufacture.toggle_flag(flag_key, flag_value)(opts, callback)
        local key = 'orbik_flag_' .. flag_key .. flag_value
        if opts[key] == nil then
          require('telescope').extensions.menufacture.toggle_flag(flag_key, flag_value)(opts, callback)
          opts[key] = true
        end
      end,
      ['toggle whole words'] = require('telescope').extensions.menufacture.toggle_flag('additional_args', '-w'),
      ['toggle case sensitive'] = require('telescope').extensions.menufacture.toggle_flag('additional_args', '--case-sensitive'),
    })
  ), { desc = 'Search with [l]ive grep' }
)
vim.keymap.set('n', '<leader>sg', function()
  local git_root = common.getGitRoot()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = {git_root},
    })
  else
    vim.api.nvim_err_writeln("Not a git repository")
  end
end, {desc = 'Search with live grep on [g]it root'})
