# Linux User Provisioning

A Bash-based Linux user provisioning tool that automates the creation and configuration of users, groups, SSH public keys, and sudo privileges using a YAML configuration file.

The script is designed to be **idempotent**, meaning it can be executed multiple times without unnecessarily recreating existing resources.

## Features

- **User management:** Create Linux users with a home directory and a specified login shell.
- **Group management:** Create required groups and assign users to supplementary groups.
- **SSH key management:** Install SSH public keys in each user's `authorized_keys` file.
- **SSH permissions:** Apply secure permissions:
  - `.ssh`: `700`
  - `authorized_keys`: `600`
- **Sudo configuration:** Grant or remove sudo privileges according to the YAML configuration.
- **Configuration validation:** Validate usernames, user settings, sudo values, and SSH public keys.
- **Dependency checks:** Verify that required system commands are available.
- **Dry-run mode:** Preview provisioning operations without modifying the system.
- **Idempotency:** Detect existing users, groups, SSH keys, and sudo rules.

## Project Structure

```text
user-provisioning/
├── config/
│   └── users.yaml
├── scripts/
│   └── provision_users.sh
└── README.md
```

## Requirements

- Linux operating system (tested on Ubuntu 24.04 LTS)
- Bash 5.x
- Root privileges for actual provisioning
- Mike Farah `yq` (YAML processor)
- `openssh-client` (`ssh-keygen`)
- `sudo` (`visudo`)
- Standard Linux administration utilities:
  - `useradd`, `usermod`, `groupadd`
  - `getent`, `id`
  - `install`, `chown`, `chmod`
  - `mktemp`, `grep`, `sort`, `cut`

## Configuration

User accounts are defined in `config/users.yaml`.

Example:

```yaml
users:
  - username: lab_alice
    shell: /bin/bash
    groups:
      - developers
    ssh_key: "ssh-ed25519 AAAA... alice@example.com"
    sudo: false

  - username: alex_lab
    shell: /bin/bash
    groups:
      - operations_team
    ssh_key: "ssh-ed25519 AAAA... alex@example.com"
    sudo: true
```

### Configuration parameters

| Parameter | Description |
|---|---|
| `username` | Linux account name |
| `shell` | User's login shell |
| `groups` | Supplementary Linux groups |
| `ssh_key` | SSH public key |
| `sudo` | Whether the user should have sudo privileges |

**Important:** Only use SSH public keys in this configuration. Never store private SSH keys or passwords in the YAML file.

## Usage

Run the commands from the root of the `linux-ops-toolbox` repository.

### 1. Validate Bash syntax

```bash
bash -n exercises/user-provisioning/scripts/provision_users.sh
```

### 2. Preview operations (dry-run)

```bash
bash exercises/user-provisioning/scripts/provision_users.sh --dry-run
```

Dry-run mode validates the configuration and displays the operations that would be performed without modifying the system.

### 3. Provision users

```bash
sudo bash exercises/user-provisioning/scripts/provision_users.sh
```

Root privileges are required for actual user and system configuration changes.

## Security Considerations

- SSH directories and key files are assigned restrictive permissions.
- Sudo rules are stored under `/etc/sudoers.d/`.
- Sudo configuration is validated using `visudo`.
- Existing unmanaged sudoers files are protected from accidental modification.
- SSH keys are validated before provisioning.
- Existing SSH keys are preserved when installing additional keys.
- Temporary files are used when updating SSH and sudo configuration.

## Testing

The following scenarios were tested on a personal Ubuntu 24.04 virtual machine:

| Test | Expected result | Status |
|---|---|---|
| Bash syntax validation | No syntax errors | Passed |
| Dependency validation | Required commands available | Passed |
| Dry-run execution | Preview without system changes | Passed |
| User creation | Accounts created successfully | Passed |
| Group creation | Required groups created | Passed |
| SSH key installation | Keys installed with correct permissions | Passed |
| Sudo configuration | Privileges match YAML settings | Passed |
| Idempotency | Existing resources detected on repeated execution | Passed |
| Duplicate username | Configuration rejected | Passed |
| Invalid SSH key | Configuration rejected | Passed |

### Useful verification commands

Check user accounts:

```bash
id lab_alice
id alex_lab
```

Check SSH permissions:

```bash
sudo stat -c '%U:%G %a %n' \
  /home/lab_alice/.ssh \
  /home/lab_alice/.ssh/authorized_keys
```

Validate sudo configuration:

```bash
sudo visudo -c
```

Inspect sudo privileges:

```bash
sudo -l -U alex_lab
```

## Key Learning Outcomes

Through this exercise, I practiced:

- Bash scripting and function-based code organization.
- Linux user and group administration.
- YAML configuration parsing with `yq`.
- SSH public-key management and file permissions.
- Sudoers configuration and validation.
- Input validation and error handling.
- Idempotent automation.
- Dry-run implementation and testing.
- Linux system administration and security practices.

## Future Improvements

- Add automated tests using ShellCheck and Bats.
- Implement stronger rollback handling for partial provisioning failures.
- Support configurable home directories and user expiration.
- Add structured logging and execution reports.
- Integrate the script into a CI pipeline.

---

**Part of my Linux & DevOps learning journey — `linux-ops-toolbox`.**
