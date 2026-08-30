{ pkgs, ... }:
let
  target = "/dev/mapper/luksRoot";

  scrub = pkgs.writeShellApplication {
    name = "btrfs-scrub";
    runtimeInputs = [
      pkgs.btrfs-progs
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.jq
    ];
    text = ''
      target=${target}
      status_file=/var/lib/btrfs-scrub/status.json

      start_output=$(btrfs scrub start -B "$target" 2>&1) && start_exit=0 || start_exit=$?

      if (( start_exit != 0 )) && grep -qi "already running" <<< "$start_output"; then
        echo "btrfs-scrub: scrub already in progress, skipping" >&2
        exit 0
      fi

      if (( start_exit != 0 )); then
        echo "$start_output" >&2
        jq -n --arg output "$start_output" --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
          '{ok: false, time: $time, output: $output}' > "$status_file"
        exit 1
      fi

      status_output=$(btrfs scrub status "$target" 2>&1)
      if grep -q "Error summary:.*no errors found" <<< "$status_output"; then
        ok=true
      else
        ok=false
      fi

      jq -n --argjson ok "$ok" --arg output "$status_output" --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{ok: $ok, time: $time, output: $output}' > "$status_file"

      if [[ "$ok" != true ]]; then
        echo "btrfs-scrub: errors found" >&2
        exit 1
      fi
    '';
  };
in
{
  systemd.services.btrfs-scrub = {
    description = "Scrub the root btrfs filesystem for errors";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${scrub}/bin/btrfs-scrub";
      TimeoutStartSec = "infinity";
      StateDirectory = "btrfs-scrub";
    };
  };

  systemd.timers.btrfs-scrub = {
    description = "Timer for weekly btrfs scrub";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun 03:00";
      Persistent = true;
      AccuracySec = "1h";
    };
  };
}
