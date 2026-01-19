{
  inputs,
  pkgs,
  ...
}:
let
  utils = inputs.nixCats.utils;
in
{
  imports = [
    inputs.nixCats.homeModule
  ];

  config = {
    nixCats = {
      enable = true;
      addOverlays = [
        (utils.standardPluginOverlay inputs)
      ];
      packageNames = [ "nvim" ];

      luaPath = "${./.}";

      categoryDefinitions.replace =
        {
          pkgs,
          ...
        }:
        {
          startupPlugins = {
            general = with pkgs.vimPlugins; [
              nvim-solarized-lua
              lualine-nvim
              nvim-web-devicons
              blink-cmp
              nvim-lint
              leap-nvim
              snacks-nvim
              orgmode
              conform-nvim
              nvim-lspconfig
              tiny-inline-diagnostic-nvim
            ];
          };
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              shellcheck
              statix
              lua-language-server
              luajitPackages.luacheck
              stylua
              nixfmt
              nixd
            ];
          };
        };

      packageDefinitions.replace = {
        nvim =
          { pkgs, ... }:
          {
            settings = {
              wrapRc = true;
              aliases = [
                "vim"
                "vi"
              ];
            };
            categories = {
              general = true;
            };
          };
      };
    };
  };
}
