{ pkgs }:
pkgs.writers.writePython3Bin "fwupd-status"
  {
    libraries = [ ];
    flakeIgnore = [ "E501" ];
  }
  ''
    import json
    import subprocess
    import sys

    try:
        result = subprocess.run(
            ["${pkgs.fwupd}/bin/fwupdmgr", "get-updates", "--json"],
            capture_output=True,
            text=True,
            timeout=15,
        )
    except subprocess.TimeoutExpired:
        print(json.dumps({"text": "FW:?", "class": "warning", "tooltip": "fwupdmgr timed out"}))
        sys.exit(0)
    except Exception as e:
        print(json.dumps({"text": "FW:?", "class": "warning", "tooltip": str(e)}))
        sys.exit(0)

    # Exit code 2 means no updates available
    if result.returncode == 2:
        print(json.dumps({"text": ""}))
        sys.exit(0)

    if result.returncode != 0:
        print(json.dumps({"text": "FW:?", "class": "warning", "tooltip": result.stderr.strip()}))
        sys.exit(0)

    try:
        data = json.loads(result.stdout)
    except json.JSONDecodeError:
        print(json.dumps({"text": "FW:?", "class": "warning", "tooltip": "JSON parse error"}))
        sys.exit(0)

    devices = data.get("Devices", [])
    count = len(devices)

    if count == 0:
        print(json.dumps({"text": ""}))
        sys.exit(0)

    tooltip_lines = []
    for device in devices:
        name = device.get("Name", "Unknown")
        releases = device.get("Releases", [])
        version = releases[0].get("Version", "?") if releases else "?"
        tooltip_lines.append(f"{name}: {version}")

    print(json.dumps({
        "text": f"FW:{count}",
        "class": "available",
        "tooltip": "\n".join(tooltip_lines),
    }))
  ''
