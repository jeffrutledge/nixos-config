vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
})

vim.lsp.enable("lua_ls")

local hostname = vim.uv.os_gethostname()
local flake_path = nixCats("nix_path") or "."

vim.lsp.config("nixd", {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
      },
      options = {
        nixos = {
          expr = string.format('(builtins.getFlake "%s").nixosConfigurations."%s".options', flake_path, hostname),
        },
      },
    },
  },
})

vim.lsp.enable("nixd")
