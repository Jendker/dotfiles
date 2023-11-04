return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',

      -- Installs the debug adapters
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Add your own debuggers here
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap-python',

      -- Miscellaneous
      'Weissle/persistent-breakpoints.nvim',
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          virt_text_pos = 'eol',
        },
      },
    },
    keys = {
      { '<F5>',       function() require('dap').continue() end,          desc = 'Debug: Start/Continue' },
      { '<F17>',      function() require('dap').close() end,             desc = 'Debug: Stop' },     -- SHIFT+F5
      { '<F29>',      function() require('dap').run_last() end,          desc = 'Debug: Run last' }, -- CTRL+F5
      { '<F6>',       function() require('dap').pause() end,             desc = 'Debug: Pause' },
      { '<F9>',       function() require('dap').continue() end,          desc = 'Debug: Start/Continue' },
      { '<F11>',      function() require('dap').step_into() end,         desc = 'Debug: Step into' },
      { '<F10>',      function() require('dap').step_over() end,         desc = 'Debug: Step over' },
      { '<F23>',      function() require('dap').step_out() end,          desc = 'Debug: Step out' }, --SHIFT+F11
      { '<F8>',       function() require('persistent-breakpoints.api').toggle_breakpoint() end, desc = 'Debug: Toggle breakpoint' },
      { '<leader>eb', function() require('persistent-breakpoints.api').toggle_breakpoint() end, desc = 'Debug: Toggle breakpoint' },
      { '<leader>ec', function() require('persistent-breakpoints.api').set_conditional_breakpoint() end, desc = 'Debug: Set conditional breakpoint' },
      { '<leader>er', function() require('persistent-breakpoints.api').clear_all_breakpoints() end, desc = 'Debug: Remove all breakpoints' },
      { '<leader>et', function() require('dapui').toggle() end,          desc = 'Debug: UI toggle' },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup()

      -- TODO set colors to red
      vim.fn.sign_define('DapBreakpoint', { text = '•'})
      vim.fn.sign_define('DapBreakpointCondition', { text = ''})

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup {
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don't feel like these are good choices.
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Set up adapter specific configs
      require('dap-go').setup()
      require('dap-python').setup(vim.fn.stdpath('data') .. "/mason/packages/debugpy/venv/bin/python3")
    end,
    cond = not_vscode
  },
  {
    'Weissle/persistent-breakpoints.nvim',
    config = function()
      require('persistent-breakpoints').setup {
        load_breakpoints_event = { "BufReadPost" }
      }
    end,
    cond = not_vscode
  },
}
