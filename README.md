# Linux Ops Toolbox

A hands-on Linux and DevOps learning project focused on Linux system administration, Bash scripting, automation, monitoring, troubleshooting, and operational best practices.

This repository contains practical exercises and small tools developed to strengthen my understanding of Linux environments and build a solid foundation in DevOps engineering.

The project is developed and tested primarily on **Ubuntu 24.04 LTS**.

---

## Project Objectives

The main goals of this project are to:

- Develop practical Linux system administration skills.
- Automate repetitive tasks using Bash scripting.
- Monitor system resources and identify potential issues.
- Manage Linux users, groups, permissions, and SSH access.
- Automate backups and implement data integrity checks.
- Analyze application logs and generate structured reports.
- Practice debugging, validation, and error handling.
- Apply Git and GitHub workflows to manage development progress.

## Tools & Technologies

| Category | Technologies |
|---|---|
| Operating System | Ubuntu 24.04 LTS |
| Shell scripting | Bash |
| Programming | Python |
| Configuration | YAML |
| YAML processing | Mike Farah `yq` |
| System administration | Linux CLI, useradd, usermod, visudo |
| Version control | Git, GitHub |
| Web server logs | Nginx |
| Data integrity | SHA-256 |

## Project Modules

### 1. System Monitoring and Health Checks

Practical scripts for monitoring Linux system resources and identifying potential resource issues.

**Implemented features:**
- Disk usage monitoring.
- Memory usage monitoring.
- System load monitoring.
- Configurable resource thresholds.
- Clear status messages and error reporting.

**Default thresholds:**
- Disk usage: 80%.
- Memory usage: 90%.
- System load: number of CPU cores × 1.0.

### 2. Backup Automation

A backup automation exercise designed to organize backups and verify data integrity.

**Implemented features:**
- Daily, weekly, and monthly backup organization.
- Configurable backup retention:
  - Daily: 7 backups.
  - Weekly: 4 backups.
  - Monthly: 12 backups.
- SHA-256 checksum generation and verification.
- Script-relative path handling.
- Backup integrity validation.

### 3. Nginx Log Analyzer

A log analysis tool that processes Nginx access logs and generates structured JSON reports.

**Main objectives:**
- Extract HTTP status codes.
- Count requests by status code.
- Summarize useful information from access logs.
- Generate machine-readable JSON output.
- Practice parsing, data processing, and error handling.

### 4. Linux User Provisioning

A YAML-driven Bash automation tool for managing Linux accounts and access permissions.

**Implemented features:**
- Create Linux users and home directories.
- Create and manage supplementary groups.
- Configure login shells.
- Install SSH public keys.
- Apply secure SSH file permissions.
- Configure and remove sudo privileges.
- Validate YAML configuration and SSH public keys.
- Detect duplicate usernames.
- Check required dependencies.
- Support dry-run execution.
- Apply idempotent provisioning operations.

The script uses `visudo` to validate sudoers configuration and protects unmanaged sudoers files from accidental modification.

See the dedicated documentation:

[`exercises/user-provisioning/README.md`](exercises/user-provisioning/README.md)

### 5. Linux Permissions and Access Control

Practical exercises covering Linux filesystem permissions and access control.

Topics include:
- `chmod` and `chown`.
- File and directory permissions.
- Ownership and groups.
- Access control concepts.
- Linux command-line troubleshooting.

---

## Repository Structure

```text
linux-ops-toolbox/
│
├── config/
│
├── docs/
│   └── learning-log.md
│
├── examples/
│
├── exercises/
│   ├── permissions/
│   ├── backup/
│   └── user-provisioning/
│       ├── config/
│       │   └── users.yaml
│       ├── scripts/
│       │   └── provision_users.sh
│       └── README.md
│
├── scripts/
│
├── tests/
│
└── README.md
```

Additional scripts and exercises are organized in their respective project directories.

## Getting Started

### Prerequisites

- Ubuntu or another compatible Linux distribution.
- Bash 5.x.
- Git.
- Python 3 for Python-based exercises.
- Additional dependencies may be required depending on the exercise.

### Clone the repository

```bash
git clone https://github.com/salimmahdaoui/linux-ops-toolbox.git
```

```bash
cd linux-ops-toolbox
```

### Explore the project

```bash
find . -maxdepth 3 -type f | sort
```

### Run a Bash script

For example, to execute the user provisioning tool in dry-run mode:

```bash
bash exercises/user-provisioning/scripts/provision_users.sh --dry-run
```

For actual provisioning, root privileges are required:

```bash
sudo bash exercises/user-provisioning/scripts/provision_users.sh
```

Refer to each exercise's documentation for its specific dependencies and execution instructions.

---

## Testing and Validation

Testing is an important part of this project.

The implemented exercises have been tested on a personal Ubuntu 24.04 virtual machine.

Examples of validation practices include:

- Bash syntax checking using `bash -n`.
- Dependency availability checks.
- Dry-run execution.
- Configuration validation.
- Duplicate username detection.
- Invalid SSH public key detection.
- Verification of file permissions and ownership.
- Sudoers validation using `visudo -c`.
- Repeated execution to verify idempotency.
- SHA-256 checksum verification for backups.

## Engineering Practices

Throughout this project, I focus on developing good operational habits:

- Writing modular and reusable scripts.
- Using meaningful function and variable names.
- Validating input before making system changes.
- Handling errors explicitly.
- Using appropriate exit codes.
- Avoiding unnecessary changes to existing system resources.
- Documenting implementation decisions and debugging experiences.
- Using Git commits to track development progress.

## Roadmap

Planned improvements include:

- [ ] Add automated shell tests using Bats.
- [ ] Integrate ShellCheck for Bash static analysis.
- [ ] Improve automated testing and edge-case coverage.
- [ ] Implement stronger rollback handling for partial provisioning failures.
- [ ] Add structured logging and execution reports.
- [ ] Explore cron and systemd timers for scheduled automation.
- [ ] Introduce Docker and container management exercises.
- [ ] Explore Ansible for configuration management.
- [ ] Build CI workflows using GitHub Actions.

## Learning Approach

This repository follows a practical, incremental learning approach:

1. Understand the Linux concept.
2. Identify a real operational problem.
3. Design a solution.
4. Implement the solution.
5. Test normal and failure scenarios.
6. Debug issues and improve the implementation.
7. Document the results.

The goal is not simply to write scripts, but to understand how Linux systems work and how to automate their administration reliably.

---

## Author

**Salim Mahdaoui**

Engineering student in Networks and Telecommunications.

Interested in:
- Linux System Administration
- DevOps Engineering
- Cloud Computing
- Infrastructure Automation
- Networking and Systems Engineering

GitHub: [@salimmahdaoui](https://github.com/salimmahdaoui)

---

*This repository is part of my continuous learning journey toward becoming a DevOps and Infrastructure Engineer.*
