return {
  {
    "saghen/blink.compat",
    lazy = false, -- Must be loaded before plugins requiring 'cmp'
    version = "*",
    opts = {},
  },
  {
    "saghen/blink.cmp",
    dependencies = { "saghen/blink.compat" },
    opts = {
      -- obsidian.nvim v3.16+ serves tags and links through obsidian-ls.
      -- Keep LSP completion enabled for markdown even if a per-filetype
      -- source list is added later.
      sources = {
        per_filetype = {
          markdown = { inherit_defaults = true, "lsp" },
        },
      },
    },
  },
}
