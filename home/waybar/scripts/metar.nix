{ pkgs }:
pkgs.writeShellScriptBin "metar" ''
  airport=KMIA
  cache_dir=~/.cache/metar_blocklet/
  mkdir -p $cache_dir

  # Update cache if older than 30s
  if [[ ! -e $cache_dir/last_cache_epoch || ! (( $(cat $cache_dir/last_cache_epoch) > $(date -d '-30sec' +%s) )) ]]; then
    taf=$(curl -m 1 -s -X 'GET' "https://aviationweather.gov/api/data/taf?ids=$airport" -H 'accept: */*')
    taf_ret=$?
    [[ $taf_ret == 0 ]] && echo "$taf" > $cache_dir/taf

    metar=$(curl -m 1 -s -X 'GET' "https://aviationweather.gov/api/data/metar?ids=$airport" -H 'accept: */*')
    metar_ret=$?
    [[ $metar_ret == 0 ]] && echo "$metar" > $cache_dir/metar

    [[ $taf_ret == 0 && $metar_ret == 0 ]] && date +%s > $cache_dir/last_cache_epoch
  fi

  taf=$(cat $cache_dir/taf | sed -r 's/^TAF //')
  metar=$(cat $cache_dir/metar | sed -r 's/^METAR //')

  metar_no_remark=$(echo "$metar" | sed -r 's/( SLP[0-9]{3}\b| T[0-9]{8}\b| [0-9]{5}$)//g' | sed -r 's/ RMK.*//g')

  # Escape for JSON
  taf_esc=$(echo "$taf" | sed 's/"/\\"/g' | tr '\n' ' ')
  metar_esc=$(echo "$metar" | sed 's/"/\\"/g')

  tooltip="$metar_esc\n\n$taf_esc"
  class=""

  # Warning if cache older than 60m
  if [[ ! -e $cache_dir/last_cache_epoch || ! (( $(cat $cache_dir/last_cache_epoch) > $(date -d '-60min' +%s) )) ]]; then
    class="warning"
  fi

  echo "{\"text\": \"$metar_no_remark\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
''
