#!/usr/bin/env python3
"""Parse an nginx access log and print a JSON summary."""
import argparse
import json
import re
import sys
from collections import Counter
from datetime import datetime

# Regex for nginx "combined" log format
LOG_RE = re.compile(
    r'(?P<ip>\S+) \S+ \S+ \[(?P<time>[^\]]+)\] '
    r'"(?P<method>\S+) (?P<path>\S+) [^"]*" '
    r'(?P<status>\d{3}) (?P<size>\d+|-)'
)

# Format of the time field: 01/Oct/2026:10:15:32 +0200
TIME_FORMAT = "%d/%b/%Y:%H:%M:%S %z"


def parse(lines, min_status=0):
    status = Counter()
    ips = Counter()
    paths = Counter()
    hours = Counter()
    total = malformed = filtered_out = 0

    for line in lines:
        m = LOG_RE.match(line)
        if not m:
            malformed += 1          # never crash on bad input
            continue

        # Convert the time text into a real date object.
        # If the text is weird, count the line as malformed.
        try:
            dt = datetime.strptime(m["time"], TIME_FORMAT)
        except ValueError:
            malformed += 1
            continue

        # Exercise 1: skip requests below --min-status
        if int(m["status"]) < min_status:
            filtered_out += 1
            continue

        total += 1
        status[m["status"]] += 1
        ips[m["ip"]] += 1
        paths[m["path"]] += 1
        hours[dt.strftime("%Y-%m-%d %H:00")] += 1   # Exercise 2
        key = dt.strftime("%Y-%m-%d %H:00")
    return {
        "total_requests": total,
        "malformed_lines": malformed,
        "filtered_out": filtered_out,
        "status_codes": dict(sorted(status.items())),
        "top_ips": ips.most_common(5),
        "top_paths": paths.most_common(5),
        "requests_per_hour": dict(sorted(hours.items())),
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("logfile", nargs="?", default="/var/log/nginx/access.log")
    ap.add_argument("--min-status", type=int, default=0,
                    help="only count requests with status >= this value")
    args = ap.parse_args()

    try:
        with open(args.logfile, encoding="utf-8", errors="replace") as f:
            result = parse(f, args.min_status)
    except FileNotFoundError:
        print(f"error: {args.logfile} not found", file=sys.stderr)
        sys.exit(2)
    except PermissionError:
        print(f"error: cannot read {args.logfile} (try sudo)", file=sys.stderr)
        sys.exit(3)

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
