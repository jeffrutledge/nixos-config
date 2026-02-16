{ pkgs }:
let
  stateFile = "/tmp/sway-caffeine";
in
{
  mkToggle =
    { lockCmd }:
    pkgs.writeShellApplication {
      name = "caffeine-toggle";
      text = ''
        if [ -f "${stateFile}" ]; then
          rm "${stateFile}"
          ${pkgs.procps}/bin/pkill -f "swayidle.*timeout 3600" || true
          ${pkgs.systemd}/bin/systemctl --user restart swayidle
        else
          touch "${stateFile}"
          ${pkgs.systemd}/bin/systemctl --user stop swayidle
          ${pkgs.swayidle}/bin/swayidle -w \
            timeout 3600 '${pkgs.systemd}/bin/systemctl suspend-then-hibernate' \
            before-sleep '${lockCmd}' \
            lock '${lockCmd}' &
        fi
        ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar || true
      '';
    };

  status = pkgs.writeShellApplication {
    name = "caffeine-status";
    text = ''
      if [ -f "${stateFile}" ]; then
        echo '{"text": "caffeine", "class": "enabled"}'
      else
        echo '{"text": "", "class": ""}'
      fi
    '';
  };
}
