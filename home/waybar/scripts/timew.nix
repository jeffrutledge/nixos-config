{ pkgs }:
pkgs.writers.writePython3Bin "timew" {
  libraries = [ ];
  flakeIgnore = [ "E501" ];
} ''
import subprocess
import datetime
import json


# Path to timew
TIMEW = "${pkgs.timewarrior}/bin/timew"


def tw_get(dom):
    try:
        bstdout = subprocess.run([TIMEW, "get", f"dom.{dom}"],
                                 check=True,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.DEVNULL).stdout
        return bstdout.decode("utf-8").strip()
    except subprocess.CalledProcessError:
        return ""


def parse_iso(iso_str):
    if not iso_str:
        return None
    # Format: 20231026T120000Z
    try:
        return datetime.datetime.strptime(iso_str, "%Y%m%dT%H%M%SZ")
    except ValueError:
        return None


def format_td(x):
    ts = x.total_seconds()
    outstr = ""
    hours, remainder = divmod(ts, 3600)
    hours = int(hours)
    if hours > 0:
        outstr += f"{hours}"
    minutes, seconds = divmod(remainder, 60)
    minutes = int(minutes)
    if hours > 0:
        outstr += f":{minutes:02d}"
    elif minutes > 0:
        outstr += f"{minutes}"
    return outstr


active = tw_get("active")
text = "TW: ERROR"
cls = "critical"

if active == "1":
    tag = tw_get("active.tag.1")
    start_str = tw_get("active.start.1")
    start_dt = parse_iso(start_str)
    if start_dt:
        duration = datetime.datetime.now() - start_dt
        text = f"TW: {tag} {format_td(duration)}"
        cls = "active"
else:
    last_end_str = tw_get("tracked.1.end")
    last_end_dt = parse_iso(last_end_str)
    if last_end_dt:
        duration = datetime.datetime.now() - last_end_dt
        text = f"TW: GAP {format_td(duration)}"
        if duration < datetime.timedelta(minutes=10):
            cls = "gap-short"
        else:
            cls = "gap-long"

print(json.dumps({"text": text, "class": cls}))
''