require "common"

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
  -- Leap and dependency
  use 'tpope/vim-repeat'
  use 'ggandor/leap.nvim'
  -- clever-f
  use 'rhysd/clever-f.vim'
  -- move lines with Alt arrows
  use 'matze/vim-move'
  -- random
  use 'tpope/vim-commentary'
  use {
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  }
  -- without VSCode
      -- auto trail whitespace
      use {
          'lewis6991/spaceless.nvim',
          config = function()
              require'spaceless'.setup()
          end,
          cond = { nocode }
      }
      use {'tpope/vim-fugitive', cond = { nocode }}
      use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true},
        config = function() require("lualine").setup(
          {sections = {lualine_x = {'filetype'}}, options = {theme = 'wombat', section_separators = '', component_separators = ''}})
        end
      }
      use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { {'nvim-lua/plenary.nvim'} },
        cond = { nocode }
      }

  if packer_bootstrap then
    require("packer").sync()
  end
end)
