require("blink.cmp").setup({
  sources = {
    default = { "lsp", "buffer", "snippets", "path" },
    -- include all "normal" files in buffer source
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
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<Tab>"] = { "accept", "fallback" },
    ["<C-l>"] = { "accept", "fallback" },
  },
  completion = {
    documentation = {
      auto_show = true,
    },
  },
})
