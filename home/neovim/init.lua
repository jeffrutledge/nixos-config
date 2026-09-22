require("settings")
require("keymaps")
require("plugins.solarized")
require("plugins.lualine")
require("plugins.blink")
require("plugins.lint")
require("plugins.leap")
require("plugins.snacks")
require("plugins.orgmode")
require("plugins.neorg")
require("plugins.conform")
require("plugins.lspconfig")
require("plugins.tiny-inline-diagnostic")
require("plugins.oil")
require("plugins.vimtex")
require("plugins.render-markdown")
require("plugins.obsidian")

-- After saving a note in the weekly notes dir, re-sync this week's open
-- tasks forward into next week's note, so next week stays current without
-- waiting for the next `wk` invocation.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.expand("~/sync/obsidian/personal/weekly") .. "/*.md",
  callback = function()
    vim.system({ "wk", "--sync" })
  end,
})
