local solarized_custom = require("lualine.themes.solarized_dark")
solarized_custom.normal.b = { fg = "#839496", bg = "#073642" }
solarized_custom.normal.c = { fg = "#839496", bg = "#002b36" }
solarized_custom.insert.b = { fg = "#839496", bg = "#073642" }
solarized_custom.insert.c = { fg = "#839496", bg = "#002b36" }
solarized_custom.visual.b = { fg = "#839496", bg = "#073642" }
solarized_custom.visual.c = { fg = "#839496", bg = "#002b36" }
solarized_custom.replace.b = { fg = "#839496", bg = "#073642" }
solarized_custom.replace.c = { fg = "#839496", bg = "#002b36" }
solarized_custom.inactive.b = { fg = "#586e75", bg = "#073642" }
solarized_custom.inactive.c = { fg = "#586e75", bg = "#002b36" }

local function lsp_status()
	local clients = vim.lsp.get_clients({ bufnr = 0 })

	if #clients == 0 then
		return "No LSP"
	end

	local names = {}
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end
	return "󰄭 " .. table.concat(names, "|")
end

require("lualine").setup({
	options = {
		theme = solarized_custom,
		icons_enabled = true,
	},
	sections = {
		lualine_a = {
			"mode",
			{
				function()
					return "SPELL"
				end,
				cond = function()
					return vim.wo.spell
				end,
			},
		},
		lualine_b = { "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { lsp_status, "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})
