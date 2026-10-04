## Phase 2: Log parser

**Problem:** Nginx logs are too big to read. I needed a summary in JSON.

**What I tried first:** awk '{print $9}' | sort | uniq -c to count status codes.

**What broke:** (write your real errors here, e.g. "forgot int() and got
TypeError when comparing string and number")

**How I debugged it:** (e.g. "read the traceback from the bottom up, found the
line number, printed the variable type with print(type(x))")

**Key commands/concepts learned:**
- Exit codes: 0 = success, non-zero = failure (2 = missing file, 3 = no permission)
- stdout is for data, stderr is for errors
- Regex named groups: (?P<name>...)
- Counter and most_common()
- Never crash on bad input: count it instead

**What I'd do differently:** (e.g. "use datetime from the start instead of slicing text")
