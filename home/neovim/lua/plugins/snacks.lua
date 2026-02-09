local function get_project_root()
  return vim.fs.root(0, { ".git", "flake.nix" }) or vim.fn.getcwd()
end

require("snacks").setup({
  picker = {},
})

vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files({ cwd = get_project_root() })
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function()
  Snacks.picker.grep({ cwd = get_project_root() })
end, { desc = "Grep" })
vim.keymap.set("n", "<leader>fl", function()
  Snacks.picker.lines()
end, { desc = "Lines" })
vim.keymap.set("n", "<leader>fL", function()
  Snacks.picker.grep_buffers()
end, { desc = "Lines all buffers" })
vim.keymap.set("n", "<leader>fb", function()
  Snacks.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", function()
  Snacks.picker.help()
end, { desc = "Help" })
