require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    nix = { "nixfmt" },
  },
  formatters = {
    stylua = {
      prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})
