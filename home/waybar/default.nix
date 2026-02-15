{ config, pkgs, ... }:
let
  c = config.theme.colors;
  f = config.theme.font;

  metarScript = import ./scripts/metar.nix { inherit pkgs; };
  wifiStatusScript = import ./scripts/wifi-status.nix { inherit pkgs; };
  pingStatusScript = import ./scripts/ping-status.nix { inherit pkgs; };
in
{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "sway-session.target";
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 24;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [ ];
        modules-right = [
          "custom/metar"
          "custom/duplicati"
          "custom/timew"
          "memory"
          "cpu"
          "bluetooth"
          "network"
          "custom/ping"
          "pulseaudio"
          "battery"
          "clock"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
          rewrite = {
            "^\\d+:(.*)$" = "$1";
          };
        };

        "custom/metar" = {
          format = "{}";
          return-type = "json";
          exec = "${metarScript}/bin/metar";
          interval = 30;
          on-click = "${pkgs.firefox}/bin/firefox --new-window https://e6bx.com/weather/KMIA/?showDecoded=1&focuspoint=metardecoder";
        };

        "memory" = {
          format = "M {percentage}%";
          interval = 30;
        };

        "cpu" = {
          format = "C {usage}%";
          interval = 30;
        };

        "bluetooth" = {
          format = " {status}";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          format-no-controller = "";
          interval = 5;
        };

        "network" = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = " {ifname}";
          format-linked = " {ifname} (No IP)";
          format-disconnected = " ";
          format-alt = "{ifname}: {essid} {ipaddr}/{cidr}";
          tooltip-format = "{ifname}: {essid} {ipaddr}/{cidr}";
          interval = 5;
          on-click-right = "${wifiStatusScript}/bin/wifi-status";
        };

        "custom/ping" = {
          format = "{}";
          return-type = "json";
          exec = "${pingStatusScript}/bin/ping-status";
          interval = 30;
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "{icon} m{volume}%";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          reverse-scrolling = 1;
        };

        "battery" = {
          states = {
            good = 95;
            warning = 20;
            critical = 10;
          };
          format = "{icon} {capacity}% {time}";
          format-charging = " {capacity}% {time}";
          format-plugged = " {capacity}% {time}";
          format-time = "{H}h{M}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          interval = 30;
          tooltip-format = "{power:.2f} W {health}/100 H";
          events = {
            on-discharging-warning = "notify-send -a 'waybar' -u normal 'Low Battery'";
            on-discharging-critical = "notify-send -a 'waybar' -u critical 'Very Low Battery'";
          };
        };

        "clock" = {
          format = "{:%Y-%m-%d %H:%M:%S %Z}";
          interval = 1;
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
      };
    };

    style = ''
      * {
        font-family: ${f.family};
        font-size: ${toString (f.size * 1.33)}px;
      }

      window#waybar {
        background-color: ${c.base03};
        color: ${c.base1};
      }

      tooltip {
        background: ${c.base03};
        border: 1px solid ${c.blue};
      }

      tooltip label {
        color: ${c.base1};
      }

      /* inactive_workspace: base03 border, base03 bg, base01 text */
      #workspaces button {
        padding: 0 5px;
        background-color: ${c.base03};
        color: ${c.base01};
        border: 2px solid ${c.base03};
      }

      /* focused_workspace: blue border, base02 bg, base1 text */
      #workspaces button.focused {
        background-color: ${c.base02};
        color: ${c.base1};
        border: 2px solid ${c.blue};
      }

      /* active_workspace: violet border, base02 bg, base1 text */
      #workspaces button.visible:not(.focused) {
        background-color: ${c.base02};
        color: ${c.base1};
        border: 2px solid ${c.violet};
      }

      /* urgent_workspace: red border, base3 bg, base01 text */
      #workspaces button.urgent {
        background-color: ${c.base3};
        color: ${c.base01};
        border: 2px solid ${c.red};
      }

      #mode {
        background-color: ${c.base02};
        border: 2px solid ${c.green};
        color: ${c.base1};
        padding: 0 10px;
      }


      #custom-metar, #custom-duplicati, #custom-timew, #memory, #cpu, #bluetooth, #network, #custom-ping, #pulseaudio, #battery, #clock {
        padding: 0 10px;
        margin: 0 2px;
        background-color: ${c.base02};
        color: ${c.base1};
      }

      #battery.charging {
        color: ${c.green};
      }

      #battery.warning:not(.charging) {
        color: ${c.orange};
      }

      #battery.critical:not(.charging) {
        color: ${c.red};
      }

      #network.disconnected {
        color: ${c.red};
      }

      #pulseaudio {
        color: ${c.blue};
      }

      #pulseaudio.muted {
        color: ${c.base1};
      }

      #custom-metar.warning {
        color: ${c.yellow};
      }

      #custom-ping.warning {
        color: ${c.yellow};
      }

      #custom-ping.critical {
        color: ${c.magenta};
      }

    '';
  };
}
