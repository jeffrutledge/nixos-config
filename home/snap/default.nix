{ pkgs, ... }:
let
  snap = pkgs.writeShellApplication {
    name = "snap";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.diffutils
    ];
    text = ''
      snap_root=/home/.snapshots

      usage() {
        cat >&2 <<'EOF'
      usage:
        snap ls FILE
        snap ls FILE VERSION
        snap restore FILE VERSION [DST] [-f]
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

      # Print the version (snapshot name) of the oldest snapshot for each
      # unique run of identical content, oldest to newest.
      list_versions() {
        require_snapshots
        local rel prev="" snap_name candidate
        rel=$(rel_path "$1")
        while IFS= read -r snap_name; do
          candidate="$snap_root/$snap_name/$rel"
          if [[ -f "$candidate" ]]; then
            if [[ -z "$prev" ]] || ! cmp -s "$prev" "$candidate"; then
              echo "$snap_name"
              prev=$candidate
            fi
          fi
        done < <(find "$snap_root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
      }

      version_path() {
        require_snapshots
        local rel candidate
        rel=$(rel_path "$1")
        if [[ ! -d "$snap_root/$2" ]]; then
          echo "snap: unknown version '$2'" >&2
          exit 1
        fi
        candidate="$snap_root/$2/$rel"
        if [[ ! -f "$candidate" ]]; then
          echo "snap: '$1' does not exist in version '$2'" >&2
          exit 1
        fi
        printf '%s\n' "$candidate"
      }

      cmd=''${1:-}
      case "$cmd" in
        ls)
          shift
          (( $# == 1 || $# == 2 )) || usage
          if (( $# == 1 )); then
            list_versions "$1"
          else
            version_path "$1" "$2"
          fi
          ;;
        restore)
          shift
          force=0
          args=()
          for a in "$@"; do
            if [[ "$a" == "-f" ]]; then
              force=1
            else
              args+=("$a")
            fi
          done
          (( ''${#args[@]} == 2 || ''${#args[@]} == 3 )) || usage
          file=''${args[0]}
          version=''${args[1]}
          src=$(version_path "$file" "$version")
          if (( ''${#args[@]} == 3 )); then
            dst=''${args[2]}
          else
            dst=$(readlink -f -- "$file")
          fi
          if [[ -e "$dst" && "$force" -ne 1 ]]; then
            echo "snap: '$dst' already exists, use -f to overwrite" >&2
            exit 1
          fi
          cp -p --reflink=auto -- "$src" "$dst"
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
        'ls:list versions of a file'
        'restore:restore a version of a file'
      )

      if (( CURRENT == 2 )); then
        _describe 'command' subcmds
        return
      fi

      local cmd=$words[2]
      local -a positional
      local i
      for (( i = 3; i < CURRENT; i++ )); do
        [[ "$words[i]" == "-f" ]] && continue
        positional+=("$words[i]")
      done

      if [[ "$cmd" == restore && "$words[CURRENT]" == -* ]]; then
        compadd -- -f
        return
      fi

      case "$cmd" in
        ls | restore)
          case $#positional in
            0) _files ;;
            1)
              local -a versions
              versions=(''${(f)"$(snap ls "$positional[1]" 2>/dev/null)"})
              compadd -a versions
              ;;
            *)
              [[ "$cmd" == restore ]] && _files
              ;;
          esac
          ;;
      esac
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
