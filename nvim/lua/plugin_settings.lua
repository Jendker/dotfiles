require "common"

-- clever-f
vim.g.clever_f_smart_case = 1
-- leap.nvim
require('leap').set_default_keymaps()
require('leap').opts.safe_labels = {}
-- Reserve space for diagnostic icons for plugins which need it
vim.opt.signcolumn = 'yes'
-- Comment c, cpp, cs, java with //
vim.api.nvim_command([[autocmd FileType c,cpp,cs,java setlocal commentstring=//\ %s]])
