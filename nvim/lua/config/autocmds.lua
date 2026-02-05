-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  command = "wincmd L",
})

vim.filetype.add({
  extension = {
    mts = "typescript",
    mtsx = "typescriptreact",
  },
})

local function follow_vault_wiki_link_or_definition()
  local ok_api, api = pcall(require, "obsidian.api")
  local ok_actions, actions = pcall(require, "obsidian.actions")
  if not (ok_api and ok_actions) then
    vim.lsp.buf.definition()
    return
  end

  local link = api.cursor_link()
  if not link then
    vim.lsp.buf.definition()
    return
  end

  actions.follow_link(link)
end

-- Turn off spell checker for markdown files in second-brain
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*/vaults/second-brain/*.md",
  callback = function()
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*/vaults/second-brain/*.md",
  callback = function()
    vim.keymap.set("n", "gd", follow_vault_wiki_link_or_definition, {
      buffer = true,
      desc = "Follow Obsidian link (vault)",
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local path = vim.api.nvim_buf_get_name(buf)
    if not path:match("/vaults/second%-brain/.*%.md$") then
      return
    end

    vim.keymap.set("n", "gd", follow_vault_wiki_link_or_definition, {
      buffer = buf,
      desc = "Follow Obsidian link (vault)",
    })
  end,
})
