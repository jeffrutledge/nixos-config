{ pkgs }:
pkgs.writeShellApplication {
  name = "fwupd-show";
  runtimeInputs = [ pkgs.fwupd ];
  text = ''
    fwupdmgr get-updates
    echo ""
    echo "To install: fwupdmgr update"
    read -r
  '';
}
