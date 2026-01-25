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
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local start = 1
  local link_text

  while true do
    local s, e = line:find("%[%[[^%]]-%]%]", start)
    if not s then
      break
    end
    if col >= s and col <= e then
      link_text = line:sub(s + 2, e - 2)
      break
    end
    start = e + 1
  end

  if not link_text then
    vim.lsp.buf.definition()
    return
  end

  local target = vim.trim(link_text:match("^[^|]+") or link_text)
  target = vim.trim(target:match("^[^#]+") or target)
  if target == "" then
    vim.lsp.buf.definition()
    return
  end

  if not target:match("%.md$") then
    target = target .. ".md"
  end

  local vault_path = vim.fn.expand("~/vaults/second-brain")
  local file_path = vault_path .. "/" .. target
  vim.fn.mkdir(vim.fn.fnamemodify(file_path, ":h"), "p")
  vim.cmd("edit " .. vim.fn.fnameescape(file_path))
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
