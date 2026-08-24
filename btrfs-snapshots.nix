{ pkgs, ... }:
let
  homeSnapshot = pkgs.writeShellApplication {
    name = "btrfs-home-snapshot";
    runtimeInputs = [
      pkgs.btrfs-progs
      pkgs.coreutils
      pkgs.findutils
    ];
    text = ''
      subvol=/home
      snap_dir=/home/.snapshots
      mkdir -p "$snap_dir"

      now=$(date +%s)
      snap_name=$(date -d "@$now" +%Y%m%dT%H%M%S)
      btrfs subvolume snapshot -r "$subvol" "$snap_dir/$snap_name"

      declare -A last_bucket

      keep_if_new_bucket() {
        local tier=$1 bucket=$2
        if [[ "''${last_bucket[$tier]:-}" != "$bucket" ]]; then
          last_bucket[$tier]=$bucket
          return 0
        fi
        return 1
      }

      mapfile -t snaps < <(find "$snap_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -r)

      for name in "''${snaps[@]}"; do
        if [[ ! "$name" =~ ^[0-9]{8}T[0-9]{6}$ ]]; then
          continue
        fi
        snap_date="''${name:0:4}-''${name:4:2}-''${name:6:2} ''${name:9:2}:''${name:11:2}:''${name:13:2}"
        epoch=$(date -d "$snap_date" +%s)
        age=$(( now - epoch ))

        keep=0
        if (( age < 3600 )); then
          keep=1
        elif (( age < 86400 )); then
          if keep_if_new_bucket hourly $(( epoch / 3600 )); then keep=1; fi
        elif (( age < 7 * 86400 )); then
          if keep_if_new_bucket daily $(( epoch / 86400 )); then keep=1; fi
        elif (( age < 26 * 7 * 86400 )); then
          if keep_if_new_bucket weekly $(( epoch / 604800 )); then keep=1; fi
        fi

        if (( keep == 0 )); then
          btrfs subvolume delete "$snap_dir/$name"
        fi
      done
    '';
  };
in
{
  environment.systemPackages = [ homeSnapshot ];

  systemd.services.btrfs-home-snapshot = {
    description = "Create and prune rolling btrfs snapshots of /home";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${homeSnapshot}/bin/btrfs-home-snapshot";
    };
  };

  systemd.timers.btrfs-home-snapshot = {
    description = "Timer for rolling btrfs snapshots of /home";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/10";
      Persistent = true;
      AccuracySec = "1min";
    };
  };
}
