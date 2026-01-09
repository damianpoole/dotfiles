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
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or {}

      -- Add obsidian sources to the default list
      vim.list_extend(opts.sources.default, { "obsidian", "obsidian_new" })

      -- Configure the providers for these sources using blink.compat
      opts.sources.providers = opts.sources.providers or {}

      opts.sources.providers.obsidian = {
        name = "obsidian",
        module = "blink.compat.source",
        score_offset = 100, -- High priority
      }

      opts.sources.providers.obsidian_new = {
        name = "obsidian_new",
        module = "blink.compat.source",
        score_offset = 100,
      }
    end,
  },
}
