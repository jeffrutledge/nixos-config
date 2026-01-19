{ pkgs }:
pkgs.writeShellApplication {
  name = "metar";
  runtimeInputs = [
    pkgs.curl
    pkgs.gnused
    pkgs.coreutils
  ];
  text = ''
    airport=KMIA
    cache_dir="$HOME/.cache/metar_blocklet"
    mkdir -p "$cache_dir"

    # Update cache if older than 30s
    if [[ ! -e "$cache_dir/last_cache_epoch" ]] || ! (( $(cat "$cache_dir/last_cache_epoch") > $(date -d '-30sec' +%s) )); then
      taf=$(curl -4 -m 5 -s -X 'GET' "https://aviationweather.gov/api/data/taf?ids=$airport" -H 'accept: */*')
      taf_ret=$?
      [[ $taf_ret == 0 ]] && echo "$taf" > "$cache_dir/taf"

      metar=$(curl -4 -m 5 -s -X 'GET' "https://aviationweather.gov/api/data/metar?ids=$airport" -H 'accept: */*')
      metar_ret=$?
      [[ $metar_ret == 0 ]] && echo "$metar" > "$cache_dir/metar"

      [[ $taf_ret == 0 && $metar_ret == 0 ]] && date +%s > "$cache_dir/last_cache_epoch"
    fi

    if [[ -f "$cache_dir/taf" ]]; then
      taf=$(cat "$cache_dir/taf" | sed -r 's/^TAF //')
    else
      taf=""
    fi

    if [[ -f "$cache_dir/metar" ]]; then
      metar=$(cat "$cache_dir/metar" | sed -r 's/^METAR //')
    else
      metar=""
    fi

    metar_no_remark=$(echo "$metar" | sed -r 's/( SLP[0-9]{3}\b| T[0-9]{8}\b| [0-9]{5}$)//g' | sed -r 's/ RMK.*//g')

    # Escape for JSON: escape quotes and replace newlines with \n
    taf_esc=$(echo "$taf" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    metar_esc=$(echo "$metar" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

    tooltip="$metar_esc\n\n$taf_esc"
    class=""

    # Warning if cache older than 60m
    if [[ ! -e "$cache_dir/last_cache_epoch" ]] || ! (( $(cat "$cache_dir/last_cache_epoch") > $(date -d '-60min' +%s) )); then
      class="warning"
    fi

    echo "{\"text\": \"$metar_no_remark\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
  '';
}
