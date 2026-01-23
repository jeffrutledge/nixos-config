{
  pkgs,
  inputs,
  config,
  ...
}:
let
  inherit (config.theme) colors;
  startpage = import ./startpage.nix { inherit pkgs colors; };
  tridactylrc = import ./tridactylrc.nix { inherit colors; };
in
{
  home.file.".config/tridactyl/tridactylrc".text = tridactylrc;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    policies = {
      "3rdparty".Extensions."addon@darkreader.org" = {
        enabled = true;
        theme = {
          mode = 1; # dark mode
          brightness = 100;
          contrast = 100;
          grayscale = 0;
          sepia = 0;
          useFont = false;
          textStroke = 0;
          darkSchemeBackgroundColor = colors.base03;
          darkSchemeTextColor = colors.base0;
          lightSchemeBackgroundColor = colors.base3;
          lightSchemeTextColor = colors.base00;
          scrollbarColor = "";
          selectionColor = "auto";
          styleSystemControls = false;
        };
      };
    };
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
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false; # Optional: also disables address/credit card autofill
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # --- COSMETIC ---
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Enable UI changes with userChrome.css
        "browser.tabs.firefox-view" = false;
        "sidebar.verticalTabs" = false; # Disable vertical tabs, use horizontal tabs at top
        "browser.startup.homepage" = "file://${startpage}";
        "browser.newtabpage.enabled" = true;
        "browser.newtab.url" = "file://${startpage}";
        "ui.key.menuAccessKeyFocuses" = false;

        # --- TRIDACTYL ---
        "extensions.tridactyl.newtab" = "true";
      };

      userChrome = ''
        /* Move tab bar below URL bar */
        #navigator-toolbox {
          display: flex !important;
          flex-direction: column !important;
        }

        #nav-bar {
          order: 1 !important;
        }

        #TabsToolbar {
          order: 2 !important;
        }

        /* Tab Bar solarized styling - compact */
        #TabsToolbar {
          background-color: ${colors.base03} !important;
          min-height: 0 !important;
          padding: 0 !important;
        }

        /* Compact tab styling */
        .tabbrowser-tab {
          background-color: ${colors.base02} !important;
          color: ${colors.base0} !important;
          min-height: 32px !important;
          max-height: 32px !important;
          padding: 0 8px !important;
        }

        .tabbrowser-tab[selected="true"] {
          background-color: ${colors.base01} !important;
          color: ${colors.base1} !important;
        }

        .tabbrowser-tab:hover:not([selected="true"]) {
          background-color: ${colors.base01} !important;
        }

        .tab-background {
          background-color: inherit !important;
          border: none !important;
          min-height: 24px !important;
          max-height: 24px !important;
        }

        .tab-background[selected="true"] {
          background-color: ${colors.base01} !important;
        }

        /* Compact tab text */
        .tab-label {
          color: inherit !important;
          font-size: 12px !important;
        }

        /* Compact tab close button */
        .tab-close-button {
          width: 16px !important;
          height: 16px !important;
        }

        /* New tab button */
        #tabs-newtab-button {
          color: ${colors.base0} !important;
          min-height: 32px !important;
          max-height: 32px !important;
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
    nativeMessagingHosts = [
      pkgs.tridactyl-native
    ];
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

  home.packages = [
    pkgs.xdg-utils
    pkgs.tridactyl-native
  ];
}
