vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

vim.keymap.set("n", "<leader>lw", function()
  vim.g.vimtex_quickfix_open_on_warning = vim.g.vimtex_quickfix_open_on_warning == 0 and 1 or 0
  print(vim.g.vimtex_quickfix_open_on_warning)
end, { buffer = true })

-- Math blackboard bold
local imaps = {
  { "pp", [[\mathbb{P}]] },
  { "ee", [[\mathbb{E}]] },
  { "cc", [[\mathbb{C}]] },
  { "rr", [[\mathbb{R}]] },
  { "qq", [[\mathbb{Q}]] },
  { "zz", [[\mathbb{Z}]] },
  { "nn", [[\mathbb{N}]] },
}
for _, m in ipairs(imaps) do
  vim.fn["vimtex#imaps#add_map"]({ lhs = m[1], rhs = m[2], wrapper = "vimtex#imaps#wrap_math" })
end

-- Math scripts
vim.fn["vimtex#imaps#add_map"]({ lhs = "sr", rhs = [[\mathscr{R}]], wrapper = "vimtex#imaps#wrap_math" })
vim.fn["vimtex#imaps#add_map"]({ lhs = "sp", rhs = [[\mathscr{P}]], wrapper = "vimtex#imaps#wrap_math" })

-- Math vars
vim.fn["vimtex#imaps#add_map"]({ lhs = "vf", rhs = [[\varphi]], wrapper = "vimtex#imaps#wrap_math" })

-- Operators
vim.fn["vimtex#imaps#add_map"]({ lhs = "/", rhs = [[\sqrt{]], wrapper = "vimtex#imaps#wrap_math" })
vim.fn["vimtex#imaps#add_map"]({ lhs = "-", rhs = [[\frac{]], wrapper = "vimtex#imaps#wrap_math" })
vim.fn["vimtex#imaps#add_map"]({ lhs = "^", rhs = [[\widehat ]], wrapper = "vimtex#imaps#wrap_math" })
