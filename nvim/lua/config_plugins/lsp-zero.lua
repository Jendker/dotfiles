if vscode then
  return
end

local status_ok, lsp_zero = pcall(require, 'lsp-zero')
if not status_ok then
  return
end

lsp_zero.preset({
  name = 'minimal',
})

-- List LSP servers that will be automatically installed upon entering filetype for the first time.
-- LSP servers will be installed locally via mason at: ~/.local/share/nvim/mason/packages/
-- (lspconfig_name => { filetypes } or true)
local auto_lsp_servers = {
  -- @see $VIMPLUG/mason-lspconfig.nvim/lua/mason-lspconfig/mappings/filetype.lua
  ['pyright'] = true,
  ['ruff_lsp'] = true,
  ['lua_ls'] = true,
  ['bashls'] = true,
  ['tsserver'] = true,
  ['cssls'] = true,
  ['clangd'] = true,
  ['rust_analyzer'] = true,
  ['texlab'] = true,
  ['yamlls'] = true,
  ['jsonlint'] = true,
  ['lemminx'] = true,  -- xml
  ['gopls'] = true,
}

--  This function gets run when an LSP connects to a particular buffer.
lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({
    buffer = bufnr,
    exclude = {'gr', '<F3>'},
    preserve_mappings = false,
  })

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('gd', "<cmd>Glance definitions<cr>", '[G]oto [d]efinition')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]ecalaration')
  nmap('gi', "<cmd>Glance implementations<cr>", '[G]oto [I]mplementation')
  nmap('gH', "<cmd>Glance references<cr>", 'Goto references')
  nmap('go', "<cmd>Glance type_definitions<cr>", 'Goto type lsp_definitions')
  nmap('gh', vim.lsp.buf.hover, '[G][H]over documentation')

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  nmap('[e', '<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>')
  nmap(']e', '<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>')

  -- Create a command `:Format` local to the LSP buffer
  if vim.fn.has("nvim-0.9.0") == 1 then
    if (client.server_capabilities.semanticTokensProvider and client.server_capabilities.semanticTokensProvider ~= 0) then
      vim.cmd('TSBufDisable highlight')
    end
  end
end)

lsp_zero.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

lsp_zero.format_on_save({
  servers = {
    ['clangd'] = {'cpp'},
  }
})

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls()
      require('lspconfig').lua_ls.setup(lua_opts)
    end,
    clangd = function()
      require('lspconfig').clangd.setup({
        on_attach = function(_, bufnr)
          vim.keymap.set('n', '<A-u>', vim.cmd.ClangdSwitchSourceHeader, { buffer = bufnr, desc = "Switch between so[u]rce / header" })
        end,
        cmd = {
          "clangd",
          "--background-index",
          "--header-insertion=never"
        },
      })
    end,
    pyright = function()
      local function get_python_path(workspace)
        local util = require('lspconfig/util')
        local path = util.path
        -- Use activated virtualenv.
        if vim.env.VIRTUAL_ENV then
          return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
        end
        -- trick to check the current directory if workspace is unset
        if workspace == nil then workspace = vim.fn.getcwd() end
        -- Find and use virtualenv in workspace directory.
        for _, pattern in ipairs({'*', '.*'}) do
          local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
          if match ~= '' then
            return path.join(path.dirname(match), 'bin', 'python')
          end
        end

        -- Fallback to system Python.
        return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
      end

      require('lspconfig').pyright.setup({
        before_init = function(_, config)
          local python_path = get_python_path(config.root_dir)
          config.settings.python.pythonPath = python_path
          vim.g.python_host_prog = python_path
          vim.g.python3_host_prog = python_path
        end
      })
    end,
    ruff_lsp = function()
      require('lspconfig').ruff_lsp.setup {
        on_attach = function(client, _)
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end,
        init_options = {
          settings = {
            -- Any extra CLI arguments for `ruff` go here.
            args = {
              "--ignore",
              "E501", -- line-too-long
              "E402", -- module-import-not-at-top-of-file
              "E731", -- lambda-assignment
            },
          }
        }
      }
    end,
    gopls = function()
      require'lspconfig'.gopls.setup{
        on_attach = function(_, _)
          vim.cmd('TSBufEnable highlight')
        end
      }
    end,
  },
})

-- Refresh or force-update mason-registry if needed (e.g. pkgs are missing)
-- and execute the callback asynchronously.
local function maybe_refresh_mason_registry_and_then(callback, opts)
  local mason_registry = require("mason-registry")
  local function notify(msg, opts)
    return vim.notify_once(msg, vim.log.levels.INFO,
      vim.tbl_deep_extend("force", { title = "config/lsp.lua" }, (opts or {})))
  end
  if vim.tbl_count(mason_registry.get_all_packages()) == 0 then
    notify("Initializing mason.nvim registry for the first time,\n" ..
               "please wait a bit until LSP servers start installed.")
    mason_registry.update(function()
      notify("Updating mason.nvim registry done.")
      vim.schedule(callback)  -- must detach
    end)
  elseif (opts or {}).force then
    notify("Updating mason.nvim registry ...")
    mason_registry.update(function()
      notify("Updating mason.nvim registry done.")
      vim.schedule(callback)  -- must detach
    end)
  else
    callback()  -- don't refresh, for fast startup
  end
end

-- Install auto_lsp_servers on demand (FileType)
local function ensure_mason_installed()
  local augroup = vim.api.nvim_create_augroup('mason_autoinstall', { clear = true })
  local lspconfig_to_package = require("mason-lspconfig.mappings.server").lspconfig_to_package
  local filetype_mappings = require("mason-lspconfig.mappings.filetype")
  local _requested = {}

  local ft_handler = {}
  for ft, lsp_names in pairs(filetype_mappings) do
    lsp_names = vim.tbl_filter(function(lsp_name)
      return auto_lsp_servers[lsp_name] == true or vim.tbl_contains(auto_lsp_servers[lsp_name] or {}, lsp_name)
    end, lsp_names)

    ft_handler[ft] = vim.schedule_wrap(function()
      for _, lsp_name in pairs(lsp_names) do
        local pkg_name = lspconfig_to_package[lsp_name]
        local ok, pkg = pcall(require("mason-registry").get_package, pkg_name)
        if ok and not pkg:is_installed() and not _requested[pkg_name] then
          _requested[pkg_name] = true
          require("mason-lspconfig.install").install(pkg)  -- async
        end
      end
    end)

    -- Create FileType handler to auto-install LSPs for the &filetype
    if vim.tbl_count(lsp_names) > 0 then
      vim.api.nvim_create_autocmd('FileType', {
        pattern = ft,
        group = augroup,
        desc = string.format('Auto-install LSP server: %s (for %s)', table.concat(lsp_names, ","), ft),
        callback = function() ft_handler[ft]() end,
        once = true,
      })
    end
  end

  -- Since this works asynchronously, apply on the already opened buffer as well
  vim.tbl_map(function(buf)
    local valid = vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted')
    if not valid then return end
    local handler = ft_handler[vim.bo[buf].filetype]
    if handler then handler() end
  end, vim.api.nvim_list_bufs())
end

maybe_refresh_mason_registry_and_then(ensure_mason_installed)

-- lsp configs are lazy-loaded or can be triggered after LSP installation,
-- so we need a way to make LSP clients attached to already existing buffers.
local attach_lsp_to_existing_buffers = vim.schedule_wrap(function()
  -- this can be easily achieved by firing an autocmd event for the open buffers.
  -- See lspconfig.configs (config.autostart)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local valid = vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'buflisted')
    if valid and vim.bo[bufnr].buftype == "" then
      local augroup_lspconfig = vim.api.nvim_create_augroup('lspconfig', { clear = false })
      vim.api.nvim_exec_autocmds("FileType", { group = augroup_lspconfig, buffer = bufnr })
    end
  end
end)

--- setup all newly installed packages
local all_known_lsps = require('mason-lspconfig.mappings.server').lspconfig_to_package
local lsp_uninstalled = {}   --- { lspconfig name => mason package name }
local mason_need_refresh = false

for lsp_name, package_name in pairs(all_known_lsps) do
  if not require('mason-registry').is_installed(package_name) then
    if not require('mason-registry').has_package(package_name) then
      mason_need_refresh = true
    end
    lsp_uninstalled[lsp_name] = package_name
  end
end

maybe_refresh_mason_registry_and_then(function()
  -- mason.nvim does not launch lsp when installed for the first time
  -- we attach a manual callback to setup LSP and launch
  for lsp_name, package_name in pairs(lsp_uninstalled) do
    local ok, pkg = pcall(require('mason-registry').get_package, package_name)
    if ok then
      pkg:on("install:success", vim.schedule_wrap(function()
        lsp_zero.setup_servers({lsp_name})
        attach_lsp_to_existing_buffers()  -- TODO: reload only the buffers that matches filetype.
      end))
    end
  end

  -- Make sure LSP clients are attached to already existing buffers prior to this config.
  attach_lsp_to_existing_buffers()
end, { force = mason_need_refresh })

-- miscellaneous

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  update_in_insert = false,
  underline = true,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
})

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
require('luasnip.loaders.from_vscode').lazy_load() -- for snippets
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp_mappings = {
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<CR>'] = cmp.mapping.confirm(),
  ['<Tab>'] = cmp.mapping(
    function(fallback)
      if cmp.visible() and cmp.get_active_entry() then
        -- completion if a cmp item is selected
        cmp.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace })
      elseif vim.fn.exists('b:_codeium_completions') ~= 0 then
        -- accept codeium completion if visible
        vim.api.nvim_input(vim.fn['codeium#Accept']() .. "<ESC>")
        -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(vim.fn['codeium#Accept']() .. "<ESC>", true, true, true), "n", true)
      elseif cmp.visible() then
        -- select first item if visible
        cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })
      elseif has_words_before() then
        -- show autocomplete
        cmp.complete()
      else
        fallback()
      end
    end, {"i","s"}),
  ['<S-Tab>'] = vim.NIL,
  ['<C-d>'] = cmp.mapping.scroll_docs(4),
  ['<C-u>'] = cmp.mapping.scroll_docs(-4),
  -- jump between placeholders
  ['<C-f>'] = cmp_action.luasnip_jump_forward(),
  ['<C-b>'] = cmp_action.luasnip_jump_backward(),
}
cmp.setup({
  mapping = cmp_mappings,
  formatting = {
    fields = {'abbr', 'menu', 'kind'},
    -- max 100 characters in item abbreviation
    format = function(entry, vim_item)
      vim_item.abbr = string.sub(vim_item.abbr, 1, 100)

      local short_name = {
        nvim_lsp = 'LSP',
        nvim_lua = 'nvim'
      }
      local menu_name = short_name[entry.source.name] or entry.source.name
      vim_item.menu = string.format('[%s]', menu_name)

      return vim_item
    end
  },
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
  performance = {
    max_view_entries = 15,
  },
})

-- Use buffer source for `/`.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  completion = { autocomplete = false },
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  completion = { autocomplete = false },
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- If you want to insert `(` after selected function
local ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
if ok then
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end

-- Taken from :help diagnostic-handlers-example
-- It reduces LSP signs to only more severe one and makes LSP signs coexist nicely with Gitsigns

-- Create a custom namespace. This will aggregate signs from all other
-- namespaces and only show the one with the highest severity on a
-- given line
local ns = vim.api.nvim_create_namespace("my_namespace")

-- Get a reference to the original signs handler
local orig_signs_handler = vim.diagnostic.handlers.signs

-- Override the built-in signs handler
vim.diagnostic.handlers.signs = {
  show = function(_, bufnr, _, opts)
    -- Get all diagnostics from the whole buffer rather than just the
    -- diagnostics passed to the handler
    local diagnostics = vim.diagnostic.get(bufnr)

    -- Find the "worst" diagnostic per line
    local max_severity_per_line = {}
    for _, d in pairs(diagnostics) do
      local m = max_severity_per_line[d.lnum]
      if not m or d.severity < m.severity then
        max_severity_per_line[d.lnum] = d
      end
    end

    -- Pass the filtered diagnostics (with our custom namespace) to
    -- the original handler
    local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
    orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
  end,
  hide = function(_, bufnr)
    orig_signs_handler.hide(ns, bufnr)
  end,
}
