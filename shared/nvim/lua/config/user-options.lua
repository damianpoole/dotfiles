-- Shared options. Loaded from lua/config/options.lua (Mac) or injected there (Omarchy).
vim.g.snacks_animate = false
vim.g.lazyvim_picker = "fzf" -- Use fzf-lua as the default picker
vim.opt.tabstop = 4

-- Indentation settings for 4 spaces
vim.opt.shiftwidth = 4 -- Number of spaces for each indentation level
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for when editing
vim.opt.expandtab = true -- Use spaces instead of tabs
