{ pkgs, inputs, ... }:
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
        sidebery
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

        # --- SIDEBERY OPTIMIZATIONS ---
        # Allows Sidebery to control hidden tabs (important for panels)
        "extensions.sidebery.control-hidden-tabs" = true;

        # Hide the sidebar header ("Sidebery" text at the top of the sidebar)
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
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
          background-color: transparent !important;
          border: none !important;
          box-shadow: none !important;
        }

        /* Auto-hide the Bookmarks Bar (Shows on hover) */
        #PersonalToolbar {
          padding: 0px !important;
          height: 2px !important;
          opacity: 0 !important;
          transition: all 0.2s ease-in-out !important;
        }
        #PersonalToolbar:hover {
          height: auto !important;
          opacity: 1 !important;
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
