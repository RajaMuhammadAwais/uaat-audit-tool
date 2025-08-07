# 🛡️ User Access Audit Tool (UAAT)

[![Shell Script](https://img.shields.io/badge/-Shell%20Script-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://www.linux.org/)
[![Security Audit](https://img.shields.io/badge/-Security%20Audit-critical?style=for-the-badge&logo=datadog&logoColor=white)](https://en.wikipedia.org/wiki/Computer_security_audit)
[![CSV Report](https://img.shields.io/badge/-CSV%20Report-005F73?style=for-the-badge&logo=microsoft-excel&logoColor=white)](https://tools.ietf.org/html/rfc4180)
[![GitHub](https://img.shields.io/badge/-GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](https://opensource.org/licenses/MIT)

## Introduction

The User Access Audit Tool (UAAT) is a shell script designed to assist large organizations in auditing user accounts, permissions, and SSH keys across their servers. It identifies users with sudo/root access, detects expired or inactive accounts, and generates a comprehensive CSV report for security teams.

## Features

- Audits `/etc/passwd` and `/etc/group`.
- Detects users with `sudo` or `root` access.
- Identifies expired or inactive user accounts.
- Checks for the presence of SSH keys in user home directories.
- Generates a detailed CSV report.
- Sends the CSV report via email to a specified security team.

## Usage

### Prerequisites

- A Linux-based system (tested on Ubuntu).
- `mailutils` package installed for email functionality. You can install it using:
  ```bash
  sudo apt-get update
  sudo apt-get install -y mailutils
  ```

### Running the Script

1. Make the script executable:
   ```bash
   chmod +x uaat.sh
   ```
2. Run the script:
   ```bash
   ./uaat.sh
   ```

### Configuration

Edit the `uaat.sh` file to configure the following variables:

- `REPORT_FILE`: The name of the CSV report file (default: `uaat_report.csv`).
- `SECURITY_EMAIL`: The email address of the security team to whom the report will be sent (default: `security@example.com`).
- `INACTIVE_THRESHOLD_DAYS`: The number of days after which an account is considered inactive (default: `90`).

## Output

The script generates a CSV file named `uaat_report.csv` (or as configured) in the same directory where the script is executed. The CSV file contains the following columns:

- **Username**: The user's login name.
- **UID**: User ID.
- **GID**: Group ID.
- **Home Directory**: The user's home directory path.
- **Shell**: The user's default shell.
- **Sudo Access**: Indicates if the user has sudo or root access (e.g., "Yes (group)", "Yes (root)", "No").
- **Account Status**: Indicates if the account is active, expired, or inactive.
- **Last Login**: The date of the user's last login.
- **Password Last Changed**: The date when the user's password was last changed.
- **Password Expires**: The date when the user's password will expire.
- **SSH Keys Found**: Indicates if SSH public keys are found in the user's `.ssh` directory.

## Limitations

- The script relies on standard Linux utilities (`/etc/passwd`, `chage`, `id`, `grep`, `awk`, `sendmail`). Ensure these are available and properly configured on your system.
- SSH key detection only checks for the presence of `.pub` files in the user's `.ssh` directory. It does not validate the keys or their contents.
- Email functionality requires a properly configured `sendmail` or compatible MTA (Mail Transfer Agent) on the system.


