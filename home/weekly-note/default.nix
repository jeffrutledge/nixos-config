{ pkgs }:
pkgs.writeShellApplication {
  name = "wk";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.gawk
    pkgs.gnugrep
  ];
  text = ''
    NOTES_DIR="$HOME/sync/obsidian/personal/weekly"

    monday_of_today() {
      local dow
      dow=$(date +%u)
      date -d "-$((dow - 1)) days" +%Y-%m-%d
    }

    week_date() {
      date -d "$1 -$(($2 * 7)) days" +%Y-%m-%d
    }

    carry_tasks() {
      awk '
        /^## Tasks[[:space:]]*$/ { intasks=1; next }
        intasks && /^## / { intasks=0 }
        intasks { print }
      ' "$1" | grep -viE '^[[:space:]]*-[[:space:]]*\[[xX]\]' || true
    }

    replace_tasks_section() {
      local dst="$1" body="$2"
      awk -v body="$body" '
        BEGIN { intasks=0; found=0 }
        /^## Tasks[[:space:]]*$/ {
          print
          printf "%s\n", body
          intasks=1
          found=1
          next
        }
        intasks && /^## / { intasks=0; print ""; print; next }
        intasks { next }
        { print }
        END {
          if (!found) { printf "\n## Tasks\n%s\n", body }
        }
      ' "$dst" >"$dst.tmp"
      mv "$dst.tmp" "$dst"
    }

    sync_tasks() {
      local src="$1" dst="$2"
      local body
      body=$(carry_tasks "$src")
      replace_tasks_section "$dst" "$body"
    }

    ensure_note() {
      local d="$1"
      local file="$NOTES_DIR/$d.md"
      if [ -f "$file" ]; then
        printf '%s\n' "$file"
        return
      fi

      mkdir -p "$NOTES_DIR"

      local prev="" check="$d" i
      for ((i = 0; i < 52; i++)); do
        check=$(week_date "$check" 1)
        if [ -f "$NOTES_DIR/$check.md" ]; then
          prev="$NOTES_DIR/$check.md"
          break
        fi
      done

      {
        printf '# Weekly %s\n\n' "$d"
        printf '## Tasks\n'
        if [ -n "$prev" ]; then
          carry_tasks "$prev"
        fi
      } >"$file"

      printf '%s\n' "$file"
    }

    sync_current_forward() {
      local current current_file next next_file
      current=$(monday_of_today)
      current_file=$(ensure_note "$current")
      next=$(date -d "$current +7 days" +%Y-%m-%d)
      next_file=$(ensure_note "$next")
      sync_tasks "$current_file" "$next_file"
      printf '%s\n' "$current_file"
    }

    main() {
      if [ "''${1:-}" = "--sync" ]; then
        sync_current_forward >/dev/null
        return
      fi

      local n=1
      if [ $# -gt 0 ]; then
        case "$1" in
        -[0-9]*)
          n="''${1#-}"
          ;;
        *)
          echo "Usage: wk [-N]" >&2
          exit 1
          ;;
        esac
      fi

      local current_file
      current_file=$(sync_current_forward)

      local current
      current=$(monday_of_today)

      local files=("$current_file")
      local i d
      for ((i = 1; i < n; i++)); do
        d=$(week_date "$current" "$i")
        files+=("$NOTES_DIR/$d.md")
      done

      if [ "''${#files[@]}" -eq 1 ]; then
        nvim "''${files[0]}"
      else
        nvim -O "''${files[@]}"
      fi
    }

    main "$@"
  '';
}
