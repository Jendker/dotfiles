if vscode then
  return
end

local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
  return
end

-- Reserve space for diagnostic icons
vim.opt.signcolumn = 'yes:2'

gitsigns.setup {
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  current_line_blame_opts = {
    delay = 100,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true, desc="Jump to next hunk"})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true, desc="Jump to previous hunk"})

    -- Actions
    map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>', { desc = "[s]tage hunk", silent = true })
    map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = "[r]eset hunk", silent = true })
    map('n', '<leader>hS', gs.stage_buffer, { desc = "[S]tage buffer", silent = true })
    map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "[u]ndo stage hunk", silent = true })
    map('n', '<leader>hR', gs.reset_buffer, { desc = "[r]eset buffer", silent = true })
    map('n', '<leader>hp', gs.preview_hunk, { desc = "[p]review hunk", silent = true })
    map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = "show full line [b]lame", silent = true })
    map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "[t]oggle current line [b]lame", silent = true })
    map('n', '<leader>hd', gs.diffthis, { desc = "[d]iff this", silent = true })
    map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = "Diff to previous commit", silent = true })
    map('n', '<leader>td', gs.toggle_deleted, { desc = "[t]oggle [d]eleted", silent = true })

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "select hunk"} )
  end
}
