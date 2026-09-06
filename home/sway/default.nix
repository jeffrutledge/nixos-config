{
  config,
  lib,
  pkgs,
  ...
}:

let
  preLockCmd = config.sway.preLockCommand;
  preLockPrefix = if preLockCmd != "" then "${preLockCmd}; " else "";
  c = config.theme.colors;
  f = config.theme.font;
  mod = "Mod1";
  move_mod = "Shift";
  m_internal = "eDP-1";
  m_external = "DP-1";
  menu = "${pkgs.rofi}/bin/rofi -show drun";
  dmenuOpts = "-i -fn '${f.family}-${toString f.size}' -nb ${c.base02} -nf ${c.base1} -sb ${c.blue} -sf ${c.base3}";
  alacrittyCwdLaunch = import ../alacritty/alacritty-cwd-launch.nix { inherit pkgs; };
  externalDisplay = import ./external-display.nix {
    inherit pkgs;
    internal = m_internal;
    external = m_external;
  };
  swaySession = import ../sway-sessions {
    inherit pkgs;
    internal = m_internal;
    external = m_external;
    focusColor = c.blue;
    visibleColor = c.violet;
    urgentColor = c.red;
    sessionColor = c.cyan;
  };
  sessionCli = "${swaySession.cli}/bin/sway-session";
  mute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ 1";
  lockCmd = "${preLockPrefix}${mute} && ${pkgs.swaylock}/bin/swaylock -fF";
  caffeine = import ../caffeine { inherit pkgs; };
  caffeineToggle = caffeine.mkToggle { inherit lockCmd; };
  brightness = import ../brightness { inherit pkgs; };
  brightnessUpdate = brightness.update;
in
{
  options.sway.preLockCommand = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Command to run before locking/sleeping";
  };

  config = {
    home.packages = with pkgs; [
      swayidle
      dmenu
    ];

    programs.swaylock = {
      enable = true;
      settings = {
        color = c.base03;
        inside-color = c.base02;
        inside-clear-color = c.base02;
        inside-ver-color = c.base02;
        inside-wrong-color = c.base02;
        key-hl-color = c.blue;
        bs-hl-color = c.orange;
        ring-color = c.base01;
        ring-clear-color = c.yellow;
        ring-ver-color = c.blue;
        ring-wrong-color = c.red;
        text-color = c.base1;
        text-clear-color = c.yellow;
        text-ver-color = c.blue;
        text-wrong-color = c.red;
        line-color = c.base03;
        line-clear-color = c.base03;
        line-ver-color = c.base03;
        line-wrong-color = c.base03;
        separator-color = c.base03;
      };
    };

    services.swayidle = {
      enable = true;
      events = {
        before-sleep = lockCmd;
        lock = lockCmd;
      };
      timeouts = [
        {
          timeout = 300; # 5 minutes of inactivity
          command = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
        }
      ];
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = mod;
        output = {
          "*" = {
            scale = "1";
          };
        };

        fonts = {
          names = [ f.family ];
          size = f.size;
        };

        window.border = 1;
        floating.modifier = mod;

        input = {
          "type:touchpad" = {
            tap = "enabled";
            click_method = "clickfinger";
            drag = "disabled";
            natural_scroll = "enabled";
            pointer_accel = "0.4";
          };
        };

        # Appearance / Colors using the theme module
        colors = {
          focused = {
            border = c.blue;
            background = c.base02;
            text = c.base1;
            indicator = c.cyan;
            childBorder = c.blue;
          };
          focusedInactive = {
            border = c.violet;
            background = c.base03;
            text = c.base01;
            indicator = c.base01;
            childBorder = c.base02;
          };
          unfocused = {
            border = c.base02;
            background = c.base03;
            text = c.base00;
            indicator = c.base01;
            childBorder = c.base02;
          };
          urgent = {
            border = c.red;
            background = c.base3;
            text = c.base01;
            indicator = c.magenta;
            childBorder = c.red;
          };
          placeholder = {
            border = "#000000";
            background = "#0c0c0c";
            text = "#ffffff";
            indicator = "#000000";
            childBorder = "#0c0c0c";
          };
          background = "#ffffff";
        };

        # Keybindings
        keybindings = lib.mkOptionDefault {
          # Basics
          "${mod}+Shift+r" = "reload";
          "${mod}+${move_mod}+q" = "kill";

          # Launching
          "${mod}+Return" = "exec ${alacrittyCwdLaunch}/bin/alacritty-cwd-launch";
          "${mod}+Shift+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          "${mod}+apostrophe" = "exec emacsclient -nc";
          "${mod}+b" = "exec ${pkgs.firefox}/bin/firefox";
          "${mod}+o" = "exec ${menu}";
          "${mod}+slash" = "exec passmenu ${dmenuOpts}";

          # Dunst
          "${mod}+x" = "exec ${pkgs.dunst}/bin/dunstctl close";
          "${mod}+${move_mod}+x" = "exec ${pkgs.dunst}/bin/dunstctl close-all";
          "${mod}+z" = "exec ${pkgs.dunst}/bin/dunstctl context";
          "${mod}+${move_mod}+z" = "exec ${pkgs.dunst}/bin/dunstctl history-pop";

          # Media / Brightness
          "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86MonBrightnessDown" =
            "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%- && ${brightnessUpdate}/bin/brightness-update";
          "XF86MonBrightnessUp" =
            "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5% && ${brightnessUpdate}/bin/brightness-update";

          # Focus / Movement (Vim-style)
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";
          "${mod}+${move_mod}+h" = "move left";
          "${mod}+${move_mod}+j" = "move down";
          "${mod}+${move_mod}+k" = "move up";
          "${mod}+${move_mod}+l" = "move right";

          # Workspace Navigation (current session's workspaces 1-10)
          "${mod}+1" = "exec ${sessionCli} goto 1";
          "${mod}+2" = "exec ${sessionCli} goto 2";
          "${mod}+3" = "exec ${sessionCli} goto 3";
          "${mod}+4" = "exec ${sessionCli} goto 4";
          "${mod}+5" = "exec ${sessionCli} goto 5";
          "${mod}+6" = "exec ${sessionCli} goto 6";
          "${mod}+7" = "exec ${sessionCli} goto 7";
          "${mod}+8" = "exec ${sessionCli} goto 8";
          "${mod}+9" = "exec ${sessionCli} goto 9";
          "${mod}+0" = "exec ${sessionCli} goto 10";

          # Workspace Navigation (current session's workspaces f1-f10, external monitor)
          "${mod}+F1" = "exec ${sessionCli} goto f1";
          "${mod}+F2" = "exec ${sessionCli} goto f2";
          "${mod}+F3" = "exec ${sessionCli} goto f3";
          "${mod}+F4" = "exec ${sessionCli} goto f4";
          "${mod}+F5" = "exec ${sessionCli} goto f5";
          "${mod}+F6" = "exec ${sessionCli} goto f6";
          "${mod}+F7" = "exec ${sessionCli} goto f7";
          "${mod}+F8" = "exec ${sessionCli} goto f8";
          "${mod}+F9" = "exec ${sessionCli} goto f9";
          "${mod}+F10" = "exec ${sessionCli} goto f10";
          "${mod}+m" = "workspace 90:msgs";
          "${mod}+t" = "workspace 91:todo";
          "${mod}+period" = "workspace 92:music";

          # Move to workspace (current session's workspaces 1-10)
          "${mod}+${move_mod}+1" = "exec ${sessionCli} move 1";
          "${mod}+${move_mod}+2" = "exec ${sessionCli} move 2";
          "${mod}+${move_mod}+3" = "exec ${sessionCli} move 3";
          "${mod}+${move_mod}+4" = "exec ${sessionCli} move 4";
          "${mod}+${move_mod}+5" = "exec ${sessionCli} move 5";
          "${mod}+${move_mod}+6" = "exec ${sessionCli} move 6";
          "${mod}+${move_mod}+7" = "exec ${sessionCli} move 7";
          "${mod}+${move_mod}+8" = "exec ${sessionCli} move 8";
          "${mod}+${move_mod}+9" = "exec ${sessionCli} move 9";
          "${mod}+${move_mod}+0" = "exec ${sessionCli} move 10";
          "${mod}+${move_mod}+F1" = "exec ${sessionCli} move f1";
          "${mod}+${move_mod}+F2" = "exec ${sessionCli} move f2";
          "${mod}+${move_mod}+F3" = "exec ${sessionCli} move f3";
          "${mod}+${move_mod}+F4" = "exec ${sessionCli} move f4";
          "${mod}+${move_mod}+F5" = "exec ${sessionCli} move f5";
          "${mod}+${move_mod}+F6" = "exec ${sessionCli} move f6";
          "${mod}+${move_mod}+F7" = "exec ${sessionCli} move f7";
          "${mod}+${move_mod}+F8" = "exec ${sessionCli} move f8";
          "${mod}+${move_mod}+F9" = "exec ${sessionCli} move f9";
          "${mod}+${move_mod}+F10" = "exec ${sessionCli} move f10";
          "${mod}+${move_mod}+m" = "move container to workspace 90:msgs";
          "${mod}+${move_mod}+t" = "move container to workspace 91:todo";
          "${mod}+${move_mod}+greater" = "move container to workspace 92:music";

          # Layouts
          "${mod}+semicolon" = "split h";
          "${mod}+v" = "split v";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+${move_mod}+w" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+space" = "focus mode_toggle";

          # Sessions (tmux-style: each session has its own workspaces 1-10, f1-f10)
          "${mod}+s" = "exec ${sessionCli} switch";
          "${mod}+${move_mod}+s" = "exec ${sessionCli} relocate";

          # Modes
          "${mod}+e" = "mode \"exit\"";
          "${mod}+d" = "mode \"display\"";
          "${mod}+r" = "mode \"resize\"";

          # Caffeine toggle
          "${mod}+c" = "exec ${caffeineToggle}/bin/caffeine-toggle";
        };

        # Workspace Assignments to Monitors
        # (session workspaces 1-10/f1-f10 are pinned to the internal/external
        # output at runtime by sway-session; only the fixed external-monitor
        # workspaces need static assignment here)
        workspaceOutputAssign = [
          {
            workspace = "90:msgs";
            output = m_external;
          }
          {
            workspace = "91:todo";
            output = m_external;
          }
          {
            workspace = "92:music";
            output = m_external;
          }
        ];

        assigns = {
          "90:msgs" = [ { class = "Thunderbird"; } ];
        };

        window.commands = [
          {
            command = "move to workspace 92:music";
            criteria = {
              class = "Spotify";
            };
          }
          {
            command = "floating enable, resize set 1000 600";
            criteria = {
              title = "^termfilechooser$";
            };
          }
        ];

        startup = [
          {
            command = "systemctl --user restart waybar";
            always = true;
          }
          {
            command = mute;
            always = false;
          }
        ];

        modes = {
          exit = {
            "l" = "mode \"default\", exec ${mute} && ${pkgs.swaylock}/bin/swaylock";
            "e" = "mode \"default\", exec swaymsg exit";
            "s" = "mode \"default\", exec ${mute} && systemctl suspend-then-hibernate";
            "h" = "mode \"default\", exec ${mute} && systemctl hibernate";
            "r" = "mode \"default\", exec systemctl reboot";
            "p" = "mode \"default\", exec systemctl poweroff";
            "Return" = "mode \"default\"";
            "Escape" = "mode \"default\"";
          };
          display = {
            "o" = "mode \"default\", exec ${externalDisplay}/bin/external-display off";
            "a" = "mode \"default\", exec ${externalDisplay}/bin/external-display on";
            "r" = "mode \"default\", exec ${externalDisplay}/bin/external-display right";
            "Return" = "mode \"default\"";
            "Escape" = "mode \"default\"";
          };
          resize = {
            "h" = "resize shrink width 10 px or 10 ppt";
            "j" = "resize shrink height 10 px or 10 ppt";
            "k" = "resize grow height 10 px or 10 ppt";
            "l" = "resize grow width 10 px or 10 ppt";
            "space" = "floating toggle";
            "s" = "sticky toggle";
            # Set horizontal size to 1/n
            "2" = "resize set width 50 ppt, mode \"default\"";
            "3" = "resize set width 33 ppt, mode \"default\"";
            "4" = "resize set width 25 ppt, mode \"default\"";
            "5" = "resize set width 20 ppt, mode \"default\"";
            "6" = "resize set width 17 ppt, mode \"default\"";
            "7" = "resize set width 14 ppt, mode \"default\"";
            "8" = "resize set width 12 ppt, mode \"default\"";
            "9" = "resize set width 11 ppt, mode \"default\"";
            "0" = "resize set width 10 ppt, mode \"default\"";
            # Set vertical size to 1/n (shift+number)
            "at" = "resize set height 50 ppt, mode \"default\"";
            "numbersign" = "resize set height 33 ppt, mode \"default\"";
            "dollar" = "resize set height 25 ppt, mode \"default\"";
            "percent" = "resize set height 20 ppt, mode \"default\"";
            "asciicircum" = "resize set height 17 ppt, mode \"default\"";
            "ampersand" = "resize set height 14 ppt, mode \"default\"";
            "asterisk" = "resize set height 12 ppt, mode \"default\"";
            "parenleft" = "resize set height 11 ppt, mode \"default\"";
            "parenright" = "resize set height 10 ppt, mode \"default\"";
            "Return" = "mode \"default\"";
            "Escape" = "mode \"default\"";
          };
        };
        bars = [ ];
        window.hideEdgeBorders = "smart";
      };

      extraConfig = ''
        # Compatibility for some xwayland apps
        xwayland enable
      '';
    };
  };
}
