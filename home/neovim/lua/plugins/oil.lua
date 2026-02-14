require("oil").setup({
  columns = {
    "permissions",
    "size",
    { "mtime", "%Y-%m-%d %H:%M" },
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
