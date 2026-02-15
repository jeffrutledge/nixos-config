{ pkgs }:

pkgs.writeShellApplication {
  name = "alacritty-cwd-launch";
  runtimeInputs = [
    pkgs.sway
    pkgs.jq
    pkgs.procps
    pkgs.coreutils
    pkgs.alacritty
  ];
  text = ''
    # Get the focused node from sway
    focused=$(swaymsg -t get_tree | jq '.. | select(.type? == "con" and .focused? == true)')

    # Extract PID and app_id/class
    pid=$(echo "$focused" | jq '.pid')
    app_id=$(echo "$focused" | jq -r '.app_id')
    class=$(echo "$focused" | jq -r '.window_properties.class')

    if [ "$app_id" = "Alacritty" ] || [ "$class" = "Alacritty" ]; then
        # Find the deepest child process (handles nested shells)
        current_pid="$pid"
        while child_pid=$(pgrep -P "$current_pid" | head -n 1); do
            current_pid="$child_pid"
        done

        cwd=$(readlink "/proc/$current_pid/cwd")

        if [ -d "$cwd" ]; then
            alacritty --working-directory "$cwd"
            exit 0
        fi
    fi

    # Fallback to default launch
    alacritty
  '';
}
