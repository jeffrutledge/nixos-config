{ pkgs, ... }:
let
  snap = pkgs.writeShellApplication {
    name = "snap";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.diffutils
      pkgs.util-linux
    ];
    text = ''
      snap_root=/home/.snapshots

      usage() {
        cat >&2 <<'EOF'
      usage:
        snap ls [FILE...]
        snap ls -s SNAP FILE...
        snap restore -s SNAP FILE... [DST] [-f]
      EOF
        exit 1
      }

      require_snapshots() {
        if [[ ! -d "$snap_root" ]]; then
          echo "snap: no snapshots found at $snap_root" >&2
          exit 1
        fi
      }

      # Resolve FILE to its path relative to /home, without requiring it to
      # currently exist (it may only exist inside old snapshots).
      rel_path() {
        local abs
        abs=$(readlink -f -- "$1")
        case "$abs" in
          /home/*) printf '%s\n' "''${abs#/home/}" ;;
          *)
            echo "snap: '$1' is not under /home" >&2
            exit 1
            ;;
        esac
      }

      # Print the snap name of the oldest snapshot for each unique run of
      # identical content, oldest to newest.
      unique_versions() {
        local rel=$1 prev="" snap_name candidate
        while IFS= read -r snap_name; do
          candidate="$snap_root/$snap_name/$rel"
          if [[ -f "$candidate" ]]; then
            if [[ -z "$prev" ]] || ! cmp -s "$prev" "$candidate"; then
              prev=$candidate
              printf '%s\n' "$snap_name"
            fi
          fi
        done < <(find "$snap_root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
      }

      # label, snap time (utc), local time - tab separated for `column -t`.
      list_versions_rows() {
        local label=$1 rel=$2 snap_name local_time
        while IFS= read -r snap_name; do
          if [[ "$snap_name" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
            local_time=$(date -d "$snap_name" +%Y-%m-%dT%H:%M:%S_%Z)
          else
            local_time=""
          fi
          printf '%s\t%s\t%s\n' "$label" "$snap_name" "$local_time"
        done < <(unique_versions "$rel")
      }

      resolve_in_snap() {
        local file=$1 snap=$2 rel candidate
        if [[ ! -d "$snap_root/$snap" ]]; then
          echo "snap: unknown snap '$snap'" >&2
          exit 1
        fi
        rel=$(rel_path "$file")
        candidate="$snap_root/$snap/$rel"
        if [[ ! -f "$candidate" ]]; then
          echo "snap: '$file' does not exist in snap '$snap'" >&2
          exit 1
        fi
        printf '%s\n' "$candidate"
      }

      ls_cmd() {
        local snap="" files=()
        while (( $# > 0 )); do
          case "$1" in
            -s)
              shift
              (( $# > 0 )) || usage
              snap=$1
              ;;
            *)
              files+=("$1")
              ;;
          esac
          shift
        done

        require_snapshots

        if [[ -n "$snap" ]]; then
          (( ''${#files[@]} >= 1 )) || usage
          local f
          for f in "''${files[@]}"; do
            resolve_in_snap "$f" "$snap"
          done
          return
        fi

        if (( ''${#files[@]} == 0 )); then
          while IFS= read -r -d ''' f; do
            files+=("$f")
          done < <(find . -mindepth 1 -maxdepth 1 -type f -not -name '.*' -printf '%f\0' | sort -z)
        fi

        local f rel
        {
          for f in "''${files[@]}"; do
            rel=$(rel_path "$f")
            list_versions_rows "$f" "$rel"
          done
        } | column -t -s $'\t'
      }

      restore_cmd() {
        local snap="" force=0 rest=()
        while (( $# > 0 )); do
          case "$1" in
            -s)
              shift
              (( $# > 0 )) || usage
              snap=$1
              ;;
            -f)
              force=1
              ;;
            *)
              rest+=("$1")
              ;;
          esac
          shift
        done

        [[ -n "$snap" ]] || usage
        (( ''${#rest[@]} >= 1 )) || usage

        require_snapshots

        local dst="" files=()
        if (( ''${#rest[@]} == 1 )); then
          files=("''${rest[0]}")
        else
          dst=''${rest[-1]}
          files=("''${rest[@]:0:''${#rest[@]}-1}")
        fi

        if (( ''${#files[@]} > 1 )) && [[ -n "$dst" && ! -d "$dst" ]]; then
          echo "snap: '$dst' is not a directory" >&2
          exit 1
        fi

        local f candidate target
        for f in "''${files[@]}"; do
          candidate=$(resolve_in_snap "$f" "$snap")

          if [[ -n "$dst" ]]; then
            if [[ -d "$dst" ]]; then
              target="$dst/$(basename -- "$f")"
            else
              target=$dst
            fi
          else
            target=$(readlink -f -- "$f")
          fi

          if [[ -e "$target" && "$force" -ne 1 ]]; then
            echo "snap: '$target' already exists, use -f to overwrite" >&2
            exit 1
          fi
          cp -p --reflink=auto -- "$candidate" "$target"
        done
      }

      cmd=''${1:-}
      case "$cmd" in
        ls)
          shift
          ls_cmd "$@"
          ;;
        restore)
          shift
          restore_cmd "$@"
          ;;
        # Used by shell completion to get raw snap names without going
        # through the column-aligned `ls` display.
        _versions)
          shift
          (( $# == 1 )) || usage
          require_snapshots
          unique_versions "$(rel_path "$1")"
          ;;
        *)
          usage
          ;;
      esac
    '';
  };

  completion = pkgs.writeTextDir "zsh/_snap" ''
    #compdef snap

    _snap() {
      local -a subcmds
      subcmds=(
        'ls:list versions of file(s)'
        'restore:restore a snapshot of file(s)'
      )

      if (( CURRENT == 2 )); then
        _describe 'command' subcmds
        return
      fi

      local cmd=$words[2]

      if [[ "$words[CURRENT-1]" == "-s" ]]; then
        local -a rest versions
        local i w
        for (( i = 3; i < CURRENT - 1; i++ )); do
          w=$words[i]
          [[ "$w" == "-s" || "$w" == "-f" ]] && continue
          [[ "$words[i-1]" == "-s" ]] && continue
          rest+=("$w")
        done
        if (( ''${#rest[@]} >= 1 )); then
          versions=(''${(f)"$(snap _versions "$rest[1]" 2>/dev/null)"})
          compadd -a versions
        fi
        return
      fi

      if [[ "$words[CURRENT]" == -* ]]; then
        if [[ "$cmd" == restore ]]; then
          compadd -- -s -f
        else
          compadd -- -s
        fi
        return
      fi

      _files
    }

    _snap "$@"
  '';
in
{
  home.packages = [ snap ];

  programs.zsh.completionInit = ''
    fpath=("${completion}/zsh" $fpath)
    autoload -U compinit && compinit
  '';
}
