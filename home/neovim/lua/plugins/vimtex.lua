vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_quickfix_mode = 2
vim.g.vimtex_quickfix_open_on_warning = 0

vim.api.nvim_create_augroup("vimtex_autocompile", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = "vimtex_autocompile",
  pattern = "VimtexEventInitPost",
  callback = function()
    vim.cmd("VimtexCompile")
  end,
})
vim.api.nvim_create_autocmd("VimLeave", {
  group = "vimtex_autocompile",
  pattern = "*.tex",
  callback = function()
    vim.cmd("!latexmk -c")
  end,
})
