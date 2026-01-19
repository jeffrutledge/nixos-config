-- Solarized dark colorscheme
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd.colorscheme("solarized")

-- Lualine statusline with darker section b
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

require("lualine").setup({
  options = {
    theme = solarized_custom,
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

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "BufEnter" }, {
  callback = function()
    vim.defer_fn(function()
      lint.try_lint()
    end, 100)
  end,
})
