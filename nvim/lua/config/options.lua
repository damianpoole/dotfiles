-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.snacks_animate = false
vim.g.lazyvim_picker = "fzf" -- Use fzf-lua as the default picker
vim.opt.tabstop = 4

-- Indentation settings for 4 spaces
vim.opt.shiftwidth = 4      -- Number of spaces for each indentation level
vim.opt.softtabstop = 4     -- Number of spaces that a <Tab> counts for when editing
vim.opt.expandtab = true    -- Use spaces instead of tabs
-- tabstop is already set to 4 above
