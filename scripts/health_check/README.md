# Linux System Healthcheck

A Bash script designed to monitor essential Linux system resources and identify potential performance issues.

## Overview

Monitoring system resources is an important part of Linux system administration and DevOps.

A server experiencing high CPU load, excessive memory usage, or insufficient disk space may become slow or unstable.

Manually checking these resources repeatedly is inefficient.

This project provides a lightweight Bash script that automatically checks the health of a Linux system and reports resource usage.

## Problem Statement

Imagine you are responsible for maintaining a Linux server hosting a web application.

One day, users start experiencing slow response times.

You need to determine whether the problem is related to:

- Insufficient disk space.
- High memory consumption.
- Excessive system load.

Checking each resource manually takes time, especially when managing multiple servers.

**Solution:** Automate these checks with a Bash script that evaluates system resource usage against predefined thresholds and reports potential warnings.

## Features

- Monitor disk space usage.
- Monitor memory usage.
- Check system load average.
- Compare resource usage against configurable thresholds.
- Display system health information.
- Report warnings when resource usage exceeds defined limits.
- Use exit codes to make the script suitable for automation and monitoring workflows.

*Keep only the features that are actually implemented in your script.*

## Monitoring Thresholds

The current project uses the following thresholds:

| Resource | Warning threshold |
|---|---:|
| Disk usage | 80% |
| Memory usage | 90% |
| System load | Number of CPU cores × 1.0 |

### Understanding the system load threshold

The load average represents the average number of processes running or waiting for CPU resources over a period of time.

For this project, the threshold is calculated using the number of available CPU cores.

For example, on a machine with 2 CPU cores:

```bash
nproc
```

Output:

```text
2
```

The load threshold is therefore:

```text
2 × 1.0 = 2.0
```

A load average above 2.0 triggers a warning according to this project's threshold policy.

**Note:** Load average is not a direct CPU utilization percentage. It also includes processes waiting for certain system resources, such as I/O.

## Requirements

- Linux operating system.
- Bash 5.x or compatible version.
- Standard Linux utilities:
  - `df`
  - `free`
  - `uptime`
  - `nproc`
  - `awk`

Check your Bash version:

```bash
bash --version
```

## Installation

Clone the repository:

```bash
git clone https://github.com/salimmahdaoui/linux-ops-toolbox.git
```

Navigate to the healthcheck directory:

```bash
cd linux-ops-toolbox
```

Locate the script:

```bash
find . -name "healthcheck.sh"
```

Make it executable:

```bash
chmod +x path/to/healthcheck.sh
```

## Usage

Run the script:

```bash
./path/to/healthcheck.sh
```

Alternatively:

```bash
bash path/to/healthcheck.sh
```

## Example Output

The following output is illustrative. Your actual output depends on the implementation and the current state of your system.

```text
====================================
       LINUX SYSTEM HEALTHCHECK
====================================

[INFO] Checking disk usage...
[OK] Disk usage: 45%

[INFO] Checking memory usage...
[OK] Memory usage: 62%

[INFO] Checking system load...
[INFO] CPU cores: 2
[INFO] Load average: 0.44
[OK] System load is normal.

====================================
       SYSTEM STATUS: HEALTHY
====================================
```

### Example: High resource usage

If disk usage exceeds the configured threshold:

```text
[WARNING] Disk usage is above 80%.
```

The script helps identify the resource that requires investigation.

## Real-World Use Case

Imagine a Linux server running a web application.

Users report that the application has become slow.

You execute the healthcheck script and discover:

| Resource | Current usage | Threshold | Status |
|---|---:|---:|---|
| Disk | 85% | 80% | Warning |
| Memory | 65% | 90% | OK |
| Load average | 0.44 | 2.0 | OK |

The disk usage is above the defined threshold.

As a DevOps engineer, you can investigate:

```bash
df -h
```

Identify large directories:

```bash
du -sh /var/log/*
```

Inspect large files and determine whether old logs, temporary files, or unnecessary backups are consuming disk space.

The healthcheck script does not automatically repair the server. It helps detect problems early and guides further troubleshooting.

## What I Learned

Through this project, I practiced:

- Writing Bash scripts for Linux administration.
- Automating system monitoring tasks.
- Understanding disk and memory usage.
- Working with Linux load averages.
- Using commands such as `df`, `free`, `uptime`, and `nproc`.
- Processing command output with `awk`.
- Implementing threshold-based checks.
- Applying automation to real-world system administration scenarios.

## Future Improvements

- Add configurable thresholds through command-line arguments.
- Generate monitoring reports in JSON format.
- Add timestamps to monitoring results.
- Log warnings to a dedicated file.
- Add support for monitoring multiple servers.
- Integrate the script into a scheduled monitoring workflow using cron.
- Export metrics to Prometheus.

## Author

**Salim Mahdaoui**

Engineering student — Networks and Telecommunications  
Interested in Linux, Cloud Computing, Networking, and DevOps.

GitHub: [@salimmahdaoui](https://github.com/salimmahdaoui)

---

Part of the [`linux-ops-toolbox`](https://github.com/salimmahdaoui/linux-ops-toolbox) project.
