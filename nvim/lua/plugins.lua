-- Indicate first time installation
local packer_bootstrap = false

-- Check if packer.nvim is installed
-- Run PackerCompile if there are changes in this file
local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
  packer_bootstrap = true
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "plugins.lua",
  command = "source <afile> | PackerSync",
})
-- Install packages
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- Lightspeed and dependency
  use 'tpope/vim-repeat'
  use 'ggandor/lightspeed.nvim'

  if packer_bootstrap then
    require("packer").sync()
  end
end)

