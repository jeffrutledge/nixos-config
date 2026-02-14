require("oil").setup({
  columns = {
    "permissions",
    "size",
    { "mtime", "%Y-%m-%d %H:%M" },
  },
  git = {
    add = function(path)
      return true
    end,
    mv = function(src_path, dest_path)
      return true
    end,
    rm = function(path)
      return true
    end,
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
