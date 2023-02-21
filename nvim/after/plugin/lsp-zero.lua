local status_ok, lsp = pcall(require, 'lsp-zero')
if not status_ok then
  return
end

lsp.preset({
  name = 'recommended',
  suggest_lsp_servers = false,
  set_lsp_keymaps = {preserve_mappings = false}
})

local cmp = require('cmp')
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.abort(),
  ['<Tab>'] = cmp.mapping.confirm(),
  ['<S-Tab>'] = nil,
})
lsp.setup_nvim_cmp({
  mapping = cmp_mappings,
  formatting = {
    -- max 100 characters in item abbreviation
    format = function(_, vim_item)
      vim_item.abbr = string.sub(vim_item.abbr, 1, 100)
      return vim_item
    end
  },
})

lsp.ensure_installed({
  -- list of servers in
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  'bashls',
  'clangd',
  'pyright',
  'lua_ls',
  'yamlls',
})
local lsp_signature_config = {
  toggle_key = '<C-h>'
}
--  This function gets run when an LSP connects to a particular buffer.
lsp.on_attach(function(_, bufnr)
  require('lsp_signature').on_attach(lsp_signature_config, bufnr)

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('gd', "<cmd>Telescope lsp_definitions<cr>", '[G]oto [D]efinition')
  nmap('gf', vim.lsp.buf.declaration, '[G]oto Decalaration')
  nmap('gI', "<cmd>Telescope lsp_implementations<cr>", '[G]oto [I]mplementation')
  nmap('gr', "<cmd>Telescope lsp_references<cr>", '[G]oto [R]eferences')
  nmap('gh', vim.lsp.buf.hover, '[G][H]over documentation')

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
end)

lsp.configure('clangd', {
  on_attach = function(_, bufnr)
    vim.keymap.set('n', '<A-u>', vim.cmd.ClangdSwitchSourceHeader, { buffer = bufnr, desc = "Switch between so[u]rce / header" })
  end,
})

lsp.configure('lua_ls', {
  Lua = {
    workspace = { checkThirdParty = false },
    telemetry = { enable = false },
  },
})

lsp.nvim_workspace()
lsp.setup()

-- vim.diagnostic.config({
--   virtual_text = true,
-- })

-- If you want to insert `(` after selected function
local ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
if ok then
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end
