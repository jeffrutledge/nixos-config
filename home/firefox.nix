{
  pkgs,
  inputs,
  config,
  ...
}:
let
  colors = config.theme.colors;
  myStartpage = pkgs.writeText "startpage.html" (builtins.readFile ./firefox/startpage.html);
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;

      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        darkreader
        tridactyl
      ];

      settings = {
        # --- WAYLAND & PERFORMANCE ---
        "gfx.webrender.all" = true;
        "widget.wayland.fractional-scale.enabled" = true;
        "widget.use-xdg-desktop-portal.file-picker" = 1; # Use system file picker

        # --- PRIVACY & SPAM ---
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "dom.security.https_only_mode" = true;
        "privacy.trackingprotection.enabled" = true;

        # --- COSMETIC ---
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Enable UI changes with userChrome.css
        "browser.tabs.firefox-view" = false;
        "browser.startup.homepage" = "file://${myStartpage}";
        "browser.newtabpage.enabled" = true;
        "browser.newtab.url" = "file://${myStartpage}";

        # --- TRIDACTYL ---
        "extensions.tridactyl.newtab" = "true";
      };

      userChrome = ''
        /* Hide the top Tab Bar */
        #TabsToolbar { 
          visibility: collapse !important; 
        }

        /* Slim down the Address Bar (URL Bar) */
        #nav-bar {
          margin-top: 0px !important;
          margin-bottom: 0px !important;
          padding-top: 2px !important;
          padding-bottom: 2px !important;
          background-color: ${colors.base03} !important;
          border: none !important;
          box-shadow: none !important;
          color: ${colors.base0} !important;
        }

        /* URL Bar colors */
        #urlbar-background {
          background-color: ${colors.base02} !important;
          border: 1px solid ${colors.base01} !important;
        }

        #urlbar-input {
          color: ${colors.base1} !important;
        }

        /* Always hide the Bookmarks Bar */
        #PersonalToolbar {
          visibility: collapse !important;
        }

        /* Remove 'Back' button when it's disabled */
        #back-button[disabled="true"] { 
          display: none !important; 
        }

        /* Round the corners of the URL bar for a modern look */
        #urlbar-input-container {
          border-radius: 8px !important;
        }

        /* Remove the "Grey line" between the URL bar and the webpage */
        #navigator-toolbox {
          border-bottom: none !important;
          background-color: ${colors.base03} !important;
        }
      '';

    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };

  home.packages = [ pkgs.xdg-utils ];
}
