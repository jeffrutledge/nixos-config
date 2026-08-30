{ pkgs }:
pkgs.writeShellApplication {
  name = "fs-status";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.jq
  ];
  text = ''
    status_file=/var/lib/btrfs-scrub/status.json

    if [[ ! -r "$status_file" ]]; then
      jq -n -c '{text: "FS", class: "critical", tooltip: "btrfs scrub has never run"}'
      exit 0
    fi

    ok=$(jq -r '.ok' "$status_file")
    time=$(jq -r '.time' "$status_file")
    output=$(jq -r '.output' "$status_file")

    stale_threshold=$(( 14 * 24 * 3600 ))
    age=$(( $(date -u +%s) - $(date -u -d "$time" +%s) ))

    if [[ "$ok" == "true" ]] && (( age < stale_threshold )); then
      jq -n -c --arg tooltip "btrfs scrub clean (last run $time)" \
        '{text: "FS", tooltip: $tooltip}'
      exit 0
    fi

    if [[ "$ok" == "true" ]]; then
      tooltip=$(printf 'btrfs scrub last ran %s, more than 2 weeks ago' "$time")
    else
      tooltip=$(printf 'btrfs scrub errors (last run %s)\n%s' "$time" "$output")
    fi
    jq -n -c --arg tooltip "$tooltip" '{text: "FS", class: "critical", tooltip: $tooltip}'
  '';
}
