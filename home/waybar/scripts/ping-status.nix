{ pkgs }:
pkgs.writeShellApplication {
  name = "ping-status";
  runtimeInputs = [
    pkgs.iputils
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.jq
  ];
  text = ''
    if ping_info=$(ping -i 0.02 -q -W 2 -c 20 8.8.8.8 2>&1); then
      loss_pct=$(echo "$ping_info" | grep 'packet loss' | cut -d, -f3 | cut -d' ' -f 2 | tr -d %)
      loss_int=$(printf %.0f "$loss_pct")

      rtt_line=$(echo "$ping_info" | grep 'rtt min')
      if [ -n "$rtt_line" ]; then
        avg_ms=$(printf %.0f "$(echo "$rtt_line" | cut -d' ' -f4 | cut -d'/' -f 2)")
        std_ms=$(printf %.0f "$(echo "$rtt_line" | cut -d' ' -f4 | cut -d'/' -f 4)")
      else
        avg_ms=0
        std_ms=0
      fi
    else
      loss_int=100
      avg_ms=0
      std_ms=0
    fi

    # Determine if we should show and what class
    class=""
    if (( loss_int == 100 )); then
      class="critical"
    elif (( loss_int > 5 )) || (( avg_ms + std_ms > 200 )); then
      class="warning"
    fi

    # Only show when there's a problem
    if [ -n "$class" ]; then
      if (( loss_int == 100 )); then
        text="''${loss_int}%"
      else
        text="''${loss_int}% ''${avg_ms}󰦒''${std_ms}ms"
      fi
      jq -n -c --arg text "$text" --arg class "$class" '{text: $text, class: $class}'
    else
      echo '{"text": ""}'
    fi
  '';
}
