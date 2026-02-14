vim.opt.relativenumber = true
vim.opt.scrolloff = 5
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.breakindent = true
vim.opt.mouse = ""
vim.opt.clipboard = "unnamedplus"

local nixos_config = vim.fn.expand(vim.env.NIXOS_CONFIG_PATH)
vim.opt.spellfile = nixos_config .. "/home/neovim/spell/en.utf-8.add"
