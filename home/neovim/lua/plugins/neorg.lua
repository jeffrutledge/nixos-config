require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.concealer"] = {
			config = {
				init_open_folds = "auto",
			},
		},
		["core.summary"] = {},
		["core.export"] = {},
		["core.esupports.metagen"] = {
			config = {
				type = "auto",
			},
		},
		["core.dirman"] = {
			config = {
				workspaces = {
					flying = "~/sync/neorg/flying",
					cooking = "~/sync/neorg/cooking",
					misc = "~/sync/neorg/misc",
				},
				default_workspace = "misc",
				use_popup = false,
			},
		},
	},
})
