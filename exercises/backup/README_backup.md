# Automated Backup & Rotation Lab

## Overview

This lab implements a Bash-based backup system that automates the creation, integrity verification, and rotation of compressed backups.

The goal is to practice Linux administration and DevOps fundamentals, including shell scripting, file management, error handling, data integrity, and backup recovery.

## Project Structure

```text
exercises/backup/
├── README.md
├── backup.sh
├── source/
│   ├── config.txt
│   ├── data.txt
│   └── readme.txt
└── backups/
    ├── daily/
    ├── weekly/
    └── monthly/
```

## Features

- **Automated archive creation:** Compresses the source directory using `tar` and `gzip`.
- **Three backup categories:** Daily, weekly, and monthly backups are stored separately.
- **Integrity verification:** Uses `gzip -t` to test compression integrity and `sha256sum` to verify file checksums.
- **Backup rotation:** Automatically removes older backups when retention limits are exceeded.
- **Error handling:** Stops the relevant backup operation if archive creation or verification fails.
- **Portable paths:** Resolves source and backup directories relative to the script location.
- **Recovery testing:** Extracts an archive into a temporary directory and compares the restored files with the original source.

## Backup Schedule

| Category | Execution condition | Retention |
|---|---|---|
| Daily | Every script execution | 7 backups |
| Weekly | Every Sunday | 4 backups |
| Monthly | On the first day of the month | 12 backups |

**Note:** Weekly and monthly backups are created only when the script runs on the corresponding day. A scheduler such as `cron` is required for unattended automation.

## Requirements

The lab uses standard Linux command-line utilities:

- Bash
- GNU `tar`
- `gzip`
- `sha256sum`
- `find`
- `sort`

## Usage

Run the script from the project root:

```bash
bash exercises/backup/backup.sh
```

Check the Bash syntax without executing the script:

```bash
bash -n exercises/backup/backup.sh
```

List the generated backups:

```bash
find exercises/backup/backups -maxdepth 2 -type f -print
```

## Integrity Verification

Each archive has an associated SHA-256 checksum file.

Example:

```text
backup-2026-10-20_22-22-53.tar.gz
backup-2026-10-20_22-22-53.tar.gz.sha256
```

Verify an archive using:

```bash
sha256sum -c exercises/backup/backups/daily/backup-2026-10-20_22-22-53.tar.gz.sha256
```

The expected result is `OK` when the archive matches the recorded checksum.

The script also uses `gzip -t` and can check the TAR archive structure with `tar -tzf`.

## Restoration Test

A backup is useful only if its contents can be recovered. The lab tests restoration without overwriting the original files.

Create a temporary directory:

```bash
RESTORE_DIR=$(mktemp -d)
```

Extract an archive into it:

```bash
tar -xzf exercises/backup/backups/daily/backup-2026-10-20_22-22-53.tar.gz \
    -C "$RESTORE_DIR"
```

Compare the restored files with the source:

```bash
diff -r exercises/backup/source "$RESTORE_DIR/source"
```

No output from `diff` indicates that the compared files are identical.

Remove the temporary test directory when finished:

```bash
rm -r -- "$RESTORE_DIR"
```

Replace the example archive filename with an archive that actually exists in your backup directory.

## Retention Policy

The rotation function:

1. Finds backup archives in the selected category.
2. Sorts their timestamp-based filenames in reverse order.
3. Keeps the newest backups up to the configured retention limit.
4. Deletes older archives and their associated checksum files.

The configured limits are:

```bash
DAILY_KEEP=7
WEEKLY_KEEP=4
MONTHLY_KEEP=12
```

Rotation runs after a successful backup operation.

## Key Concepts Learned

- Bash functions, variables, conditions, and exit codes
- Absolute paths and script-relative path resolution
- Compressed archives with `tar` and `gzip`
- SHA-256 checksums and data integrity
- Automated retention and file cleanup
- Error handling and safe testing
- Restoration and comparison of recovered data
- Scheduling recurring jobs with `cron`

## Future Improvements

- Configure and test a `cron` schedule.
- Add timestamped logs and clearer error reporting.
- Test restoration automatically after backup creation.
- Add safeguards for insufficient disk space and interrupted backups.
- Consider off-site or remote storage for disaster recovery.

## Learning Outcome

This lab demonstrates a practical backup workflow: **create, verify, retain, and restore**. It provides hands-on experience with Linux operations, Bash automation, and basic reliability practices used in DevOps environments.

