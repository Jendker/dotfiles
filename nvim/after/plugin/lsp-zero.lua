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
lsp.on_attach(function(_, bufnr)
  require('lsp_signature').on_attach(lsp_signature_config, bufnr)
end)
lsp.nvim_workspace()
lsp.setup()
-- If you want to insert `(` after selected function
local ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
if ok then
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end
