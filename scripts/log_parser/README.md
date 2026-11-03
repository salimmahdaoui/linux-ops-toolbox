# Nginx Log Parser

A Python-based tool for analyzing Nginx access logs and transforming raw log data into structured JSON reports.

## Overview

Web servers generate access logs containing useful information about incoming HTTP requests, response status codes, client IP addresses, requested resources, and response sizes.

When a server handles thousands of requests, manually inspecting these logs becomes time-consuming.

This project aims to automate log analysis by parsing Nginx access logs, extracting relevant information, and generating structured JSON output.

## Problem Statement

Imagine a production website experiencing unexpected errors.

Users report that some pages are unavailable or that requests are failing. The DevOps engineer needs to investigate the server logs to identify possible problems.

Manually analyzing thousands of log entries is inefficient.

**Solution:** Use a Python script to process access logs automatically and generate a readable report that helps identify HTTP errors and unusual request patterns.

## Features

- Read and process Nginx access log files.
- Extract information from HTTP requests.
- Identify HTTP response status codes.
- Count requests by status code.
- Generate structured JSON output.
- Help identify unsuccessful requests and potential server-side issues.

*Note: These features describe the intended project scope. Keep only the features implemented in your actual script.*

## Example Nginx Log Entry

```text
192.168.1.10 - - [03/Nov/2026:10:15:30 +0100] "GET /index.html HTTP/1.1" 200 1024
192.168.1.11 - - [03/Nov/2026:10:15:31 +0100] "GET /products HTTP/1.1" 200 2048
192.168.1.12 - - [03/Nov/2026:10:15:32 +0100] "GET /old-page HTTP/1.1" 404 512
192.168.1.13 - - [03/Nov/2026:10:15:33 +0100] "GET /api/users HTTP/1.1" 500 128
```

Each entry contains information such as:

| Field | Description |
|---|---|
| IP address | Client making the request |
| Timestamp | Date and time of the request |
| HTTP method | GET, POST, PUT, DELETE, etc. |
| Requested resource | Requested URL or endpoint |
| HTTP version | Protocol version |
| Status code | Server response |
| Response size | Number of bytes returned |

## Example Output

The following is an illustrative JSON report, not a guaranteed representation of the script's exact output.

```json
{
  "total_requests": 4,
  "status_codes": {
    "200": 2,
    "404": 1,
    "500": 1
  }
}
```

This report helps identify:

- Successful requests (`200`).
- Missing resources (`404`).
- Internal server errors (`500`).

## Requirements

- Linux or another operating system with Python support.
- Python 3.
- Nginx access logs or a compatible log file.

Check your Python installation:

```bash
python3 --version
```

## Usage

Clone the repository:

```bash
git clone https://github.com/salimmahdaoui/linux-ops-toolbox.git
cd linux-ops-toolbox
```

Navigate to the directory containing the script:

```bash
find . -name "log_parser.py"
```

Run the script using its supported arguments.

For example, if it accepts a log-file path:

```bash
python3 log_parser.py access.log
```

**Important:** Adapt this command to the actual argument format implemented in `log_parser.py`.

## Real-World Use Case

Consider a website receiving 10,000 HTTP requests:

| HTTP Status | Requests |
|---|---:|
| 200 | 8,500 |
| 404 | 500 |
| 500 | 1,000 |

A high number of `500` responses may indicate a backend application failure, database connectivity issue, or another server-side problem.

The parser helps the DevOps engineer identify the error distribution and decide which logs or services to investigate next.

The parser does not automatically fix server problems. It supports troubleshooting by making log information easier to analyze.

## What I Learned

Through this project, I practiced:

- Python scripting and file handling.
- Processing structured and semi-structured text.
- Extracting information from log entries.
- Using regular expressions, if implemented.
- Working with dictionaries and counters.
- Generating JSON output.
- Understanding HTTP status codes.
- Applying automation to a practical DevOps troubleshooting scenario.

## Future Improvements

- Add filtering by HTTP status code.
- Identify the most frequently requested endpoints.
- Detect suspicious request patterns.
- Generate reports with timestamps.
- Add command-line options using `argparse`.
- Integrate the parser into a scheduled monitoring workflow.

## Author

**Salim Mahdaoui**

Engineering student — Networks and Telecommunications  
Interested in Linux, Cloud Computing, Networking, and DevOps.

GitHub: [@salimmahdaoui](https://github.com/salimmahdaoui)

---

Part of the [`linux-ops-toolbox`](https://github.com/salimmahdaoui/linux-ops-toolbox) project.
