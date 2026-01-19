require("blink.cmp").setup({
  sources = {
    default = { "lsp", "buffer", "snippets", "path" },
    providers = {
      buffer = {
        opts = {
          get_bufnrs = function()
            return vim.tbl_filter(function(bufnr)
              return vim.bo[bufnr].buftype == ""
            end, vim.api.nvim_list_bufs())
          end,
        },
      },
    },
  },
  keymap = {
    preset = "default",
  },
  completion = {
    documentation = {
      auto_show = true,
    },
  },
})
