{
  pkgs,
  internal,
  external,
}:

let
  swaymsg = "${pkgs.sway}/bin/swaymsg";
  jq = "${pkgs.jq}/bin/jq";
in
pkgs.writeShellScriptBin "external-display" ''
  # Function to get output property (width or height)
  get_dim() {
    output_name=$1
    dim=$2
    # Query sway for output information and extract the dimension
    ${swaymsg} -t get_outputs | ${jq} -r ".[] | select(.name == \"$output_name\") | .rect.$dim"
  }

  case $1 in
    off) 
      ${swaymsg} output ${external} disable
      ;;
    on)
      # "a" mode: Enable external ABOVE internal
      # First enable both to ensure they are present in get_outputs
      ${swaymsg} output ${internal} enable output ${external} enable
      
      # Get height of external monitor to calculate internal's Y offset
      ext_height=$(get_dim "${external}" "height")
      
      # Fallback if detection fails
      if [ -z "$ext_height" ] || [ "$ext_height" = "null" ]; then
        echo "Warning: Could not detect height of ${external}. Defaulting to 1080." >&2
        ext_height=1080
      fi
      
      # Apply positions: External at (0,0), Internal at (0, external_height)
      ${swaymsg} output ${external} pos 0 0 output ${internal} pos 0 $ext_height
      ;;
    right)
      # "r" mode: Enable external RIGHT of internal
      ${swaymsg} output ${internal} enable output ${external} enable
      
      # Get width of internal monitor to calculate external's X offset
      int_width=$(get_dim "${internal}" "width")
      
      if [ -z "$int_width" ] || [ "$int_width" = "null" ]; then
        echo "Warning: Could not detect width of ${internal}. Defaulting to 1920." >&2
        int_width=1920
      fi
      
      # Apply positions: Internal at (0,0), External at (internal_width, 0)
      ${swaymsg} output ${internal} pos 0 0 output ${external} pos $int_width 0
      ;;
    *)
      echo "Usage: external-display {off|on|right}"
      exit 1
      ;;
  esac
''
