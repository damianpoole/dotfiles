return {
  "elanmed/fzf-lua-frecency.nvim",
  dependencies = { "ibhagwan/fzf-lua" },
  opts = {
    all_files = true,
    fzf_opts = {
      ["--no-sort"] = false,
    },
  },
  config = function(_, opts)
    require("fzf-lua-frecency").setup(opts)
  end,
  keys = {
    {
      "<leader><space>",
      function()
        require("fzf-lua-frecency").frecency()
      end,
      desc = "Find files (frecency)",
    },
  },
}
