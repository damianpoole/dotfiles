return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  config = function()
    require("render-markdown").setup({
      checkbox = {
        custom = {
          important = { highlight = "DiffDelete", raw = "[!]", rendered = " " },
          question = { highlight = "DiagnosticInfo", raw = "[?]", rendered = " " },
        },
      },
      heading = {
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
        sign = { false },
        border = { true },
      },
      -- heading = { above = " ", below = " ", border = true, icons = { " " }, sign = false },
    })
  end,
}
