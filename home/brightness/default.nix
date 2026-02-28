{ pkgs }:
let
  timestampFile = "/tmp/sway-brightness-timestamp";
in
{
  update = pkgs.writeShellApplication {
    name = "brightness-update";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      date +%s > "${timestampFile}"
      ${pkgs.procps}/bin/pkill -SIGRTMIN+9 waybar || true
      (sleep 4 && ${pkgs.procps}/bin/pkill -SIGRTMIN+9 waybar || true) &
    '';
  };

  status = pkgs.writeShellApplication {
    name = "brightness-status";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      current_time=$(date +%s)

      if [ -f "${timestampFile}" ]; then
        last_change=$(cat "${timestampFile}")
        time_diff=$((current_time - last_change))

        if [ $time_diff -le 3 ]; then
          brightness=$(${pkgs.brightnessctl}/bin/brightnessctl get)
          max_brightness=$(${pkgs.brightnessctl}/bin/brightnessctl max)
          percentage=$((brightness * 100 / max_brightness))
          echo "{\"text\": \"󰃠 $percentage%\", \"class\": \"visible\"}"
        else
          echo '{"text": "", "class": ""}'
        fi
      else
        echo '{"text": "", "class": ""}'
      fi
    '';
  };
}
