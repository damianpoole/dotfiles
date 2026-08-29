-- Unique filename so this folds into Omarchy's nvim without clashing with
-- lua/config/keymaps.lua. LazyVimKeymaps fires after LazyVim's defaults, so
-- these replace <leader>- (split below) and <leader><space> (files).
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimKeymaps",
  callback = function()
    vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })

    vim.keymap.set({ "n", "v" }, "<leader>-", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })

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

    -- Console Log Variable
    vim.keymap.set("n", "<leader>cv", function()
      local word = vim.fn.expand("<cword>")
      local line = "console.log('" .. word .. ":', " .. word .. ");"
      vim.api.nvim_put({ line }, "l", true, true)
    end, { desc = "Console Log Variable" })

    -- Vault Statistics (from obsidian-stats.nvim)
    vim.keymap.set("n", "<leader>oS", "<cmd>ObsidianStats<cr>", { desc = "Vault Statistics" })
  end,
})

return {}
