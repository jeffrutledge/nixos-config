{ config, ... }:
let
  colors = config.theme.colors;
in
{
  programs.zathura = {
    enable = true;
    options = {
      window-title-basename = true;

      notification-error-bg = colors.base03;
      notification-error-fg = colors.red;
      notification-warning-bg = colors.base03;
      notification-warning-fg = colors.yellow;
      notification-bg = colors.base03;
      notification-fg = colors.base0;

      completion-group-bg = colors.base03;
      completion-group-fg = colors.base0;
      completion-bg = colors.base02;
      completion-fg = colors.base0;
      completion-highlight-bg = colors.base01;
      completion-highlight-fg = colors.base0;

      index-bg = colors.base03;
      index-fg = colors.base0;
      index-active-bg = colors.base02;
      index-active-fg = colors.base0;

      inputbar-bg = colors.base03;
      inputbar-fg = colors.base0;

      statusbar-bg = colors.base02;
      statusbar-fg = colors.base01;

      highlight-color = "rgba(181, 137, 0, 0.5)";
      highlight-fg = colors.base3;
      highlight-active-color = "rgba(220, 50, 47, 0.5)";

      default-bg = colors.base03;
      default-fg = colors.base0;
      render-loading = true;
      render-loading-fg = colors.base03;
      render-loading-bg = colors.base0;
    };
  };
}
