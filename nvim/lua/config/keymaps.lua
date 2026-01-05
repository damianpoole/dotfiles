-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })

-- Override LazyVim's default <leader><space> to use frecency instead
vim.keymap.set("n", "<leader><space>", function()
  -- Use frecency plugin with cwd_only and all_files set to show all files in CWD
  -- sorted by frecency score (like VS Code's Cmd+P)
  require("fzf-lua-frecency").frecency({
    cwd = vim.fn.getcwd(),
    cwd_only = true, -- Limit to current directory
    all_files = true, -- Show all files, not just those with scores
  })
end, { desc = "Find files (frecency)" })

vim.keymap.set("n", "<leader>fp", "<cmd>FzfLua files cwd=%:p:h<cr>", { desc = "Find Files (Buffer Dir)" })

-- Toggle Spellcheck
vim.keymap.set("n", "<leader>us", function()
  vim.opt.spell = not (vim.opt.spell:get())
end, { desc = "Toggle Spellcheck" })

-- vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
-- vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
-- vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
-- vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')
