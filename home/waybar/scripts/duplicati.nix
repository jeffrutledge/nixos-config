{ pkgs }:
pkgs.writers.writePython3Bin "duplicati" {
  libraries = [ pkgs.python3Packages.requests pkgs.python3Packages.python-dateutil ];
  flakeIgnore = [ "E501" ];
} ''
import sys
import datetime
import urllib.parse
import json
import requests
import dateutil.parser


def format_td(x):
    ts = x.total_seconds()
    outstr = ""
    days, remainder = divmod(ts, 3600 * 24)
    days = int(days)
    if days > 0:
        outstr += f"{days}d"
    hours, remainder = divmod(remainder, 3600)
    hours = int(hours)
    if hours > 0:
        outstr += f"{hours:02d}h" if outstr else f"{hours}h"
    minutes, seconds = divmod(remainder, 60)
    minutes = int(minutes)
    if minutes > 0:
        outstr += f"{minutes:02d}" if outstr else f"{minutes}"
    return outstr


baseurl = "http://localhost:8200"
try:
    login_result = requests.get(baseurl, allow_redirects=True, verify=True, timeout=2)
    login_result.encoding = "utf-8-sig"
    token = urllib.parse.unquote(login_result.cookies["xsrf-token"])
    info_result = requests.get(
        f"{baseurl}/api/v1/backup/2",
        headers={"X-XSRF-TOKEN": token},
        cookies={"xsrf-token": token},
        verify=True,
        timeout=5
    )
    info_result.encoding = "utf-8-sig"
    last_backup_finished = info_result.json()["data"]["Backup"]["Metadata"]["LastBackupFinished"]
    last_backup_finished = dateutil.parser.parse(last_backup_finished)
    now_utc = datetime.datetime.now(datetime.timezone.utc)
    time_since_last_backup = now_utc - last_backup_finished
except Exception as e:
    print(json.dumps({"text": "BK: FAILED", "class": "critical", "tooltip": str(e)}))
    sys.exit(0)

if time_since_last_backup < datetime.timedelta(days=2):
    print(json.dumps({"text": "BK", "class": "good", "tooltip": "Backup recent"}))
else:
    outstr = f"BK: {format_td(time_since_last_backup)}"
    print(json.dumps({"text": outstr, "class": "warning", "tooltip": "Backup overdue"}))
''