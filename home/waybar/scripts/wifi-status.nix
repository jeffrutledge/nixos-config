{ pkgs }:
pkgs.writeShellApplication {
  name = "wifi-status";
  runtimeInputs = [
    pkgs.iputils
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.libnotify
  ];
  text = ''
    if ping_info=$(ping -i 0.02 -q -W 2 -c 20 8.8.8.8 2>&1); then
      loss_pct=$(echo "$ping_info" | grep 'packet loss' | cut -d, -f3 | cut -d' ' -f 2 | tr -d %)

      # Extract timing stats
      rtt_line=$(echo "$ping_info" | grep 'rtt min')
      if [ -n "$rtt_line" ]; then
        avg_ms=$(printf %.0f "$(echo "$rtt_line" | cut -d' ' -f4 | cut -d'/' -f 2)")
        std_ms=$(printf %.2f "$(echo "$rtt_line" | cut -d' ' -f4 | cut -d'/' -f 4)")
        ping_stats="$(printf %.0f "$loss_pct")% ''${avg_ms}󰦒''${std_ms}ms"
      else
        ping_stats="$(printf %.0f "$loss_pct")% loss (no RTT data)"
      fi
    else
      ping_stats="No connection"
    fi

    notify-send -a wifi_blocklet "WiFi Stats" "$ping_stats"
  '';
}
