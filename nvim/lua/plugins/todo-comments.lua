return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    highlight = {
      -- This is the "magic" setting:
      -- It tells the plugin to highlight the keyword even if it's not in a comment
      comments_only = false,
      pattern = [[.*<(KEYWORDS)\s*:]], -- Match keywords followed by a colon
    },
  },
}
