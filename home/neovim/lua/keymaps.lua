vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "<leader>jd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<leader>jD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "<leader>gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<leader>gd", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>fi", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>gi", vim.lsp.buf.incoming_calls, opts)
    vim.keymap.set("n", "<leader>go", vim.lsp.buf.outgoing_calls, opts)
  end,
})

-- Completion menu navigation (C-j/C-k)
vim.keymap.set("i", "<C-j>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-j>"
end, { expr = true })
vim.keymap.set("i", "<C-k>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-k>"
end, { expr = true })

-- Toggle spell
vim.keymap.set("n", "<leader>s", ":setlocal spell! spelllang=en_us<CR>", { desc = "Toggle spell" })

-- Write buffer
vim.keymap.set("n", "<leader>w", ":wa<CR>", { desc = "Write all" })
vim.keymap.set("i", "<leader>w", "<Esc>:wa<CR>a", { desc = "Write all" })

-- Delete buffer
vim.keymap.set("n", "<leader>db", ":bd<CR>", { desc = "Delete buffer" })

-- Insert date/time
vim.keymap.set("n", "<leader>it", function()
  vim.api.nvim_put({ os.date("%Y-%m-%d %H%M %Z") }, "c", true, true)
end, { desc = "Insert datetime" })
vim.keymap.set("i", "<leader>it", function()
  return os.date("%Y-%m-%d %H%M %Z")
end, { expr = true, desc = "Insert datetime" })
vim.keymap.set("n", "<leader>id", function()
  vim.api.nvim_put({ os.date("%Y-%m-%d") }, "c", true, true)
end, { desc = "Insert date" })
vim.keymap.set("i", "<leader>id", function()
  return os.date("%Y-%m-%d")
end, { expr = true, desc = "Insert date" })
