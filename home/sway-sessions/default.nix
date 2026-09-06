{
  pkgs,
  internal,
  external,
  focusColor ? "blue",
  visibleColor ? "violet",
  urgentColor ? "red",
  sessionColor ? "cyan",
}:
let
  swaymsg = "${pkgs.sway}/bin/swaymsg";
  jq = "${pkgs.jq}/bin/jq";

  # Session workspaces are named "<session>:<slot>", where slot is one of
  # "1".."10" (pinned to the internal output) or "f1".."f10" (pinned to the
  # external output). The session name always starts with a letter, so
  # these never collide with the numeric-prefixed fixed workspaces (like
  # "90:msgs") that aren't part of any session.
  sessionNameRe = "^[a-zA-Z][a-zA-Z0-9_-]*$";
  sessionWorkspaceRe = "^[a-zA-Z][a-zA-Z0-9_-]*:f?[0-9]+$";

  currentSessionJq = ''
    ( [.[] | select(.output == "${internal}" and .visible == true) | .name] | .[0] // "" ) as $n
    | if ($n | test("${sessionWorkspaceRe}"))
      then ($n | split(":")[0])
      else "main"
      end
  '';

  # Shared by the CLI and the bar: which output a slot belongs on.
  outputForSlotSh = ''
    output_for_slot() {
      case "$1" in
      f*) printf '%s' "${external}" ;;
      *) printf '%s' "${internal}" ;;
      esac
    }
  '';
in
{
  cli = pkgs.writeShellApplication {
    name = "sway-session";
    text = ''
      STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/sway-sessions"
      mkdir -p "$STATE_DIR/last"

      # Canonical slot order: 1-10 (internal), then f1-f10 (external).
      SLOTS=(1 2 3 4 5 6 7 8 9 10 f1 f2 f3 f4 f5 f6 f7 f8 f9 f10)

      ${outputForSlotSh}

      current_session() {
        ${swaymsg} -t get_workspaces | ${jq} -r '
          ${currentSessionJq}
        '
      }

      focused_workspace_name() {
        ${swaymsg} -t get_workspaces | ${jq} -r '[.[] | select(.focused) | .name] | .[0] // empty'
      }

      workspace_exists() {
        local name="$1"
        ${swaymsg} -t get_workspaces \
          | ${jq} -e --arg name "$name" 'any(.[]; .name == $name)' >/dev/null
      }

      list_sessions() {
        ${swaymsg} -t get_workspaces | ${jq} -r '
          [ .[].name | select(test("${sessionWorkspaceRe}")) | split(":")[0] ] | unique | .[]
        '
      }

      # Prompt via rofi for a session name (existing, picked from a list, or
      # freshly typed). Prints the validated name and returns 0, or returns
      # 1 if the user cancelled or typed something invalid.
      pick_session() {
        local prompt="$1" sessions choice
        sessions=$(list_sessions)
        if [ -n "$sessions" ]; then
          choice=$(printf '%s\n' "$sessions" | ${pkgs.rofi}/bin/rofi -dmenu -p "$prompt" || true)
        else
          choice=$(${pkgs.rofi}/bin/rofi -dmenu -p "$prompt" </dev/null || true)
        fi
        [ -z "$choice" ] && return 1

        if ! [[ "$choice" =~ ${sessionNameRe} ]]; then
          ${pkgs.libnotify}/bin/notify-send "sway-session" \
            "Invalid session name '$choice': must start with a letter and contain only letters, numbers, - and _"
          return 1
        fi
        printf '%s' "$choice"
      }

      # Move the just-created (and now focused) workspace onto the correct
      # output for its slot, since a brand new workspace lands on whichever
      # output is currently focused.
      pin_if_new() {
        local existed="$1" slot="$2"
        if [ "$existed" = "no" ]; then
          ${swaymsg} "move workspace to output $(output_for_slot "$slot")" >/dev/null
        fi
      }

      goto() {
        local slot="$1" session target existed
        session=$(current_session)
        target="$session:$slot"
        if workspace_exists "$target"; then existed=yes; else existed=no; fi
        ${swaymsg} "workspace $target" >/dev/null
        pin_if_new "$existed" "$slot"
      }

      move() {
        local slot="$1" session target existed original
        session=$(current_session)
        target="$session:$slot"
        if workspace_exists "$target"; then existed=yes; else existed=no; fi
        original=$(focused_workspace_name)
        ${swaymsg} "move container to workspace $target" >/dev/null
        if [ "$existed" = "no" ]; then
          # Newly created: hop over to pin it on the right output, then
          # return focus to where we started, matching "move container to
          # workspace" not stealing focus.
          ${swaymsg} "workspace $target" >/dev/null
          pin_if_new "no" "$slot"
          if [ -n "$original" ]; then
            ${swaymsg} "workspace $original" >/dev/null
          fi
        fi
      }

      switch() {
        local choice n target existed
        choice=$(pick_session "session") || exit 0

        n=1
        if [ -f "$STATE_DIR/last/$choice" ]; then
          n=$(<"$STATE_DIR/last/$choice")
        fi
        target="$choice:$n"
        if workspace_exists "$target"; then existed=yes; else existed=no; fi
        ${swaymsg} "workspace $target" >/dev/null
        pin_if_new "$existed" "$n"
      }

      slot_index() {
        local target="$1" i
        for i in "''${!SLOTS[@]}"; do
          if [ "''${SLOTS[$i]}" = "$target" ]; then
            printf '%s' "$i"
            return 0
          fi
        done
        return 1
      }

      # Find a free slot for $session, preferring $preferred; if taken,
      # walk the canonical slot order (wrapping past f10 back to 1) until a
      # free one turns up. Prints the slot and returns 0, or returns 1 if
      # every slot in the session is occupied.
      find_free_slot() {
        local session="$1" preferred="$2" idx total count candidate
        if ! workspace_exists "$session:$preferred"; then
          printf '%s' "$preferred"
          return 0
        fi
        if ! idx=$(slot_index "$preferred"); then
          return 1
        fi
        total=''${#SLOTS[@]}
        count=1
        while [ "$count" -lt "$total" ]; do
          candidate="''${SLOTS[$(( (idx + count) % total ))]}"
          if ! workspace_exists "$session:$candidate"; then
            printf '%s' "$candidate"
            return 0
          fi
          count=$((count + 1))
        done
        return 1
      }

      # Move the whole current workspace (not just the focused window) into
      # another session, keeping focus on it.
      relocate() {
        local current_ws src_session slot target_session final_slot
        current_ws=$(focused_workspace_name)
        if [[ "$current_ws" =~ ^([a-zA-Z][a-zA-Z0-9_-]*):(f?[0-9]+)$ ]]; then
          src_session="''${BASH_REMATCH[1]}"
          slot="''${BASH_REMATCH[2]}"
        else
          ${pkgs.libnotify}/bin/notify-send "sway-session" \
            "Current workspace \"$current_ws\" isn't part of a session; nothing to move."
          exit 1
        fi

        target_session=$(pick_session "move to session") || exit 0
        if [ "$target_session" = "$src_session" ]; then
          exit 0
        fi

        if ! final_slot=$(find_free_slot "$target_session" "$slot"); then
          ${pkgs.libnotify}/bin/notify-send "sway-session" \
            "Session \"$target_session\" has no free workspace slots"
          exit 1
        fi

        ${swaymsg} "rename workspace to \"$target_session:$final_slot\"" >/dev/null
        ${swaymsg} "move workspace to output $(output_for_slot "$final_slot")" >/dev/null
      }

      main() {
        case "''${1:-}" in
        current)
          current_session
          ;;
        goto)
          [ $# -ge 2 ] || {
            echo "Usage: sway-session goto SLOT" >&2
            exit 1
          }
          goto "$2"
          ;;
        move)
          [ $# -ge 2 ] || {
            echo "Usage: sway-session move SLOT" >&2
            exit 1
          }
          move "$2"
          ;;
        switch)
          switch
          ;;
        relocate)
          relocate
          ;;
        *)
          echo "Usage: sway-session {current|goto SLOT|move SLOT|switch|relocate}" >&2
          exit 1
          ;;
        esac
      }

      main "$@"
    '';
  };

  bar = pkgs.writeShellApplication {
    name = "sway-session-bar";
    text = ''
      STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/sway-sessions"
      mkdir -p "$STATE_DIR/last"

      render() {
        local ws_json session focused_n
        ws_json=$(${swaymsg} -t get_workspaces)

        session=$(printf '%s' "$ws_json" | ${jq} -r '
          ${currentSessionJq}
        ')

        focused_n=$(printf '%s' "$ws_json" | ${jq} -r --arg session "$session" '
          [ .[] | select((.name | startswith($session + ":")) and .visible) | (.name | split(":")[1]) ] | .[0] // empty
        ')
        if [ -n "$focused_n" ]; then
          printf '%s' "$focused_n" >"$STATE_DIR/last/$session"
        fi

        printf '%s' "$ws_json" | ${jq} -c --arg session "$session" '
          (
            [ .[] | select(.name | startswith($session + ":"))
              | (.name | split(":")[1]) as $slot
              | { slot: $slot,
                  sort_key: (if ($slot | startswith("f")) then (100 + ($slot[1:] | tonumber)) else ($slot | tonumber) end),
                  focused, visible, urgent } ]
            | sort_by(.sort_key)
          ) as $swin
          | (
            [ .[] | select(.name | test("^[0-9]+:")) ]
            | sort_by(.num)
            | map(.name | sub("^[0-9]+:"; ""))
          ) as $fixed
          | ($swin | map(
              if .focused then "<span foreground=\"${focusColor}\"><b>[\(.slot)]</b></span>"
              elif .urgent then "<span foreground=\"${urgentColor}\">!\(.slot)!</span>"
              elif .visible then "<span foreground=\"${visibleColor}\">(\(.slot))</span>"
              else .slot
              end
            ) | join(" ")
          ) as $swin_text
          | ($fixed | join(" ")) as $fixed_text
          | {
              text: ("<span foreground=\"${sessionColor}\"><b>" + $session + "</b></span>  " + $swin_text
                     + (if ($fixed_text | length) > 0 then "   " + $fixed_text else "" end)),
              tooltip: ("session: " + $session),
              class: (if ($swin | map(.urgent) | any) then "urgent" else "" end)
            }
        '
      }

      main() {
        render || true
        while true; do
          ${swaymsg} -t subscribe -m '["workspace","window","output"]' | while read -r _event; do
            render || true
          done
          sleep 1
        done
      }

      main
    '';
  };
}
