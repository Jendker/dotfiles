if vscode then
  return
end

local status_ok, lsp = pcall(require, 'lsp-zero')
if not status_ok then
  return
end

lsp.preset({
  name = 'minimal',
  manage_nvim_cmp = {set_basic_mappings = true, set_extra_mappings = true},
})

local mason_ensure_installed = {
  -- accepts only LSP servers. List of servers in
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  'bashls',
  'clangd',
  'pyright',
  'lua_ls',
  'yamlls',
}
lsp.ensure_installed(mason_ensure_installed)

-- this will install any mason package, even formatters and linters
local mason_install_if_system_command_not_available = {'jq'}

local null_ls = require('null-ls')
local mason_packages_to_source_if_available = {
  black = null_ls.builtins.formatting.black,
  yapf = null_ls.builtins.formatting.yapf,
  jq = null_ls.builtins.formatting.jq,
  cspell = {
    null_ls.builtins.diagnostics.cspell.with({
      -- Force the severity to be HINT
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity.HINT
      end,
    }),
    null_ls.builtins.code_actions.cspell
  },
  misspell = null_ls.builtins.diagnostics.misspell.with({
    -- Force the severity to be HINT
    diagnostics_postprocess = function(diagnostic)
      diagnostic.severity = vim.diagnostic.severity.HINT
    end,
  }),
  shellcheck = null_ls.builtins.diagnostics.shellcheck,
}

local lsp_signature_config = {
  toggle_key = '<C-h>'
}
--  This function gets run when an LSP connects to a particular buffer.
lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({
    buffer = bufnr,
    omit = {'gr', '<C-k>'},
    preserve_mappings = false,
  })
  require('lsp_signature').on_attach(lsp_signature_config, bufnr)

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('gd', "<cmd>Telescope lsp_definitions<cr>", '[G]oto [D]efinition')
  nmap('gf', vim.lsp.buf.declaration, '[G]oto Decalaration')
  nmap('gi', "<cmd>Telescope lsp_implementations<cr>", '[G]oto [I]mplementation')
  nmap('gH', "<cmd>Telescope lsp_references<cr>", 'Goto references')
  nmap('go', "<cmd>Telescope lsp_type_definitions<cr>", 'Goto type lsp_definitions')
  nmap('gh', vim.lsp.buf.hover, '[G][H]over documentation')
  nmap('<leader>bs', require('telescope.builtin').lsp_document_symbols, '[B]uffer [s]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [s]ymbols')

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
  if client.server_capabilities.documentRangeFormattingProvider then
    vim.keymap.set('v', '=', '<cmd>lua vim.lsp.buf.format()<cr><esc>')
    vim.keymap.set('n', '==', function()
      vim.lsp.buf.format({
        range = {
          ["start"] = vim.api.nvim_win_get_cursor(0),
          ["end"] = vim.api.nvim_win_get_cursor(0),
        }
      })
    end)
  end
end)

lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

lsp.format_on_save({
  format_opts = {
    timeout_ms = 10000,
  },
  servers = {
    ['null-ls'] = {}, -- add like = {'python', 'lua'} etc.
    ['clangd'] = {'cpp'},
  }
})

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

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls({
  Lua = {
    workspace = { checkThirdParty = false },
    telemetry = { enable = false },
  },
}))
lsp.setup()

-- null-ls

-- this has to be called after lsp.setup()
-- see https://github.com/VonHeikemen/lsp-zero.nvim/issues/60#issuecomment-1363800412
local null_ls_options = lsp.build_options('null-ls', {})

local function has_value (tab, val)
  for _, value in ipairs(tab) do
    if value == val then return true end
  end
  return false
end

local mason_installed_packages = require('mason-registry').get_installed_package_names()

local Package = require "mason-core.package"
local registry = require "mason-registry"
local install_package = function(pkg_specifier)
  local package_name, version = Package.Parse(pkg_specifier)
  local pkg = registry.get_package(package_name)
  if not pkg:is_installed() then
    pkg:install{version = version}
  end
end
for _, mason_package in ipairs(mason_install_if_system_command_not_available) do
  if not has_value(mason_installed_packages, mason_package) then
    if vim.fn.executable(mason_package) ~= 1 then
      install_package(mason_package)
    end
  end
end

local null_ls_builtin_sources = {}

for package, builtin in pairs(mason_packages_to_source_if_available) do
  if has_value(mason_installed_packages, package) or has_value(mason_install_if_system_command_not_available, package) then
    local done = false
    for _, b in ipairs(builtin) do
      -- this runs only for arrays
      table.insert(null_ls_builtin_sources, b)
      done = true
    end
    if not done then
      -- if the previous didn't run - is not an array - run this
      table.insert(null_ls_builtin_sources, builtin)
    end
  end
end

null_ls.setup({
  on_attach = null_ls_options.on_attach,
  sources = null_ls_builtin_sources
})

-- miscellaneous

vim.diagnostic.config({
  virtual_text = false,
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
local cmp_mappings = {
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<CR>'] = cmp.mapping.confirm(),
  ['<Tab>'] = cmp.mapping.confirm(),
  ['<S-Tab>'] = nil,
  ['<C-d>'] = cmp.mapping.scroll_docs(4),
  ['<C-u>'] = cmp.mapping.scroll_docs(-4),
  -- jump between placeholders
  ['<C-f>'] = cmp_action.luasnip_jump_forward(),
  ['<C-b>'] = cmp_action.luasnip_jump_backward(),
}
cmp.setup({
  mapping = cmp_mappings,
  formatting = {
    -- max 100 characters in item abbreviation
    format = function(_, vim_item)
      vim_item.abbr = string.sub(vim_item.abbr, 1, 100)
      return vim_item
    end
  },
  preselect = cmp.PreselectMode.Item,
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
})


-- If you want to insert `(` after selected function
local ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
if ok then
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end