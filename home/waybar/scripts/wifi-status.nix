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
    # ping google DNS to get some connection stats
    # Note: -i 0.02 might require root/capabilities on some systems
    ping_info=$(ping -i 0.02 -q -w 1 -c 20 8.8.8.8)

    loss_pct=$(echo "$ping_info" | grep 'packet loss' | cut -d, -f3 | cut -d' ' -f 2 | tr -d %)

    # Extract timing stats
    rtt_line=$(echo "$ping_info" | grep 'rtt min')
    avg_ms=$(printf %.0f "$(echo "$rtt_line" | cut -d' ' -f4 | cut -d'/' -f 2)")
    std_ms=$(printf %.2f "$(echo "$rtt_line" | cut -d' ' -f4 | cut -d'/' -f 4)")

    ping_stats="$(printf %.0f "$loss_pct")% ''${avg_ms}󰦒''${std_ms}ms"

    notify-send -t 2000 -a wifi_blocklet "WiFi Stats" "$ping_stats"
  '';
}
