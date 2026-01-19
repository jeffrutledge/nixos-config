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
        # Get the child process (shell) of the alacritty instance
        # pgrep -P returns the child PIDs. We take the first one.
        child_pid=$(pgrep -P "$pid" | head -n 1)

        if [ -n "$child_pid" ]; then
            # Get the current working directory of the child process
            cwd=$(readlink "/proc/$child_pid/cwd")

            if [ -d "$cwd" ]; then
                alacritty --working-directory "$cwd"
                exit 0
            fi
        fi
    fi

    # Fallback to default launch
    alacritty
  '';
}
