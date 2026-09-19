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

    sync_tasks() {
      local src="$1" dst="$2"
      local tasks
      tasks=$(carry_tasks "$src")
      [ -z "$tasks" ] && return

      local existing
      existing=$(carry_tasks "$dst")

      local new_lines=() line
      while IFS= read -r line; do
        [ -z "$line" ] && continue
        if ! grep -qxF -- "$line" <<<"$existing"; then
          new_lines+=("$line")
        fi
      done <<<"$tasks"

      [ "''${#new_lines[@]}" -eq 0 ] && return

      local add
      add=$(printf '%s\n' "''${new_lines[@]}")
      add="$add"$'\n'

      awk -v add="$add" '
        BEGIN { intasks=0; injected=0; found=0; blanks="" }
        /^## Tasks[[:space:]]*$/ { print; intasks=1; found=1; next }
        intasks && /^## / {
          if (!injected) { printf "%s", add; injected=1 }
          printf "%s", blanks
          blanks=""
          intasks=0
          print
          next
        }
        intasks && /^[[:space:]]*$/ { blanks = blanks $0 "\n"; next }
        intasks {
          if (blanks != "") { printf "%s", blanks; blanks="" }
          print
          next
        }
        { print }
        END {
          if (intasks) {
            if (!injected) { printf "%s", add; injected=1 }
            printf "%s", blanks
          }
          if (!found) { printf "\n## Tasks\n%s", add }
        }
      ' "$dst" >"$dst.tmp"
      mv "$dst.tmp" "$dst"
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

    main() {
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

      local current
      current=$(monday_of_today)

      local files=()
      local current_file
      current_file=$(ensure_note "$current")
      files+=("$current_file")

      local next="" next_file=""
      next=$(date -d "$current +7 days" +%Y-%m-%d)
      next_file="$NOTES_DIR/$next.md"
      if [ -f "$next_file" ]; then
        sync_tasks "$current_file" "$next_file"
      else
        ensure_note "$next" >/dev/null
      fi

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
