return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = { -- or tsserver if you use the older one
          filetypes = { "typescript", "typescriptreact", "mts", "mtsx" },
        },
      },
    },
  },
}
