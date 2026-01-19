{ config, pkgs, ... }:
let
  c = config.theme.colors;
  f = config.theme.font;

  metarScript = import ./scripts/metar.nix { inherit pkgs; };
  duplicatiScript = import ./scripts/duplicati.nix { inherit pkgs; };
  timewScript = import ./scripts/timew.nix { inherit pkgs; };
  wifiStatusScript = import ./scripts/wifi-status.nix { inherit pkgs; };
in
{
  programs.waybar = {
    enable = true;
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
          on-click = "${pkgs.libnotify}/bin/notify-send -t 60000 -a metar_blocklet METAR-TAF \"$(${pkgs.coreutils}/bin/cat ~/.cache/metar_blocklet/metar)\" ";
          on-click-right = "${pkgs.chromium}/bin/chromium --new-window https://e6bx.com/weather/KMIA/?showDecoded=1&focuspoint=metardecoder";
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
          on-scroll-up = "${wifiStatusScript}/bin/wifi-status";
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
            warning = 30;
            critical = 15;
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
        color: ${c.base0};
      }

      tooltip {
        background: ${c.base03};
        border: 1px solid ${c.blue};
      }

      tooltip label {
        color: ${c.base0};
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: ${c.base0};
      }

      #workspaces button.focused {
        background-color: ${c.base02};
        color: ${c.base1};
        border-bottom: 2px solid ${c.blue};
      }

      #custom-metar, #custom-duplicati, #custom-timew, #memory, #cpu, #bluetooth, #network, #pulseaudio, #battery, #clock {
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

    '';
  };
}
