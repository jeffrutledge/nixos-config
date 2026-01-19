-- Solarized dark colorscheme
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd.colorscheme("solarized")

-- Lualine statusline
require("lualine").setup({
	options = {
		theme = "solarized_dark",
		icons_enabled = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})

-- blink.cmp completion
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

-- nvim-lint
local lint = require("lint")

lint.linters_by_ft = {
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	nix = { "statix" },
	lua = { "luacheck" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	callback = function()
		lint.try_lint()
	end,
})
