local lint = require("lint")

lint.linters_by_ft = {
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	nix = { "statix" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "BufEnter" }, {
	callback = function()
		vim.defer_fn(function()
			lint.try_lint()
		end, 100)
	end,
})
