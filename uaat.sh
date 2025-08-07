#!/bin/bash

# User Access Audit Tool (UAAT)

# Configuration variables
REPORT_FILE="uaat_report.csv"
SECURITY_EMAIL="security@example.com"

# Function to audit /etc/passwd and /etc/group
audit_users_and_groups() {
  echo "Auditing users and groups..."
 

  
  USER_DATA=""

  while IFS=':' read -r username _ uid gid _ home_dir shell; do
    if [ "$uid" -ge 1000 ] && [ "$uid" -ne 65534 ]; then # Exclude system users and nobody
      USER_DATA+="$username:$uid:$gid:$home_dir:$shell:"

      # Check for sudo access
      SUDO_ACCESS="No"
      if id -nG "$username" | grep -qw "sudo\|wheel"; then
        SUDO_ACCESS="Yes (group)"
      fi
      if [ "$uid" -eq 0 ]; then
        SUDO_ACCESS="Yes (root)"
      fi
      USER_DATA+="$SUDO_ACCESS:"

    
      ACCOUNT_STATUS="Active"
      LAST_LOGIN="N/A"
      PASS_LAST_CHANGE="N/A"
      PASS_EXPIRES="N/A"

      CHAGE_INFO=$(chage -l "$username" 2>/dev/null)
      if CHAGE_INFO=$(chage -l "$username" 2>/dev/null); then
        LAST_LOGIN=$(echo "$CHAGE_INFO" | grep "Last login" | awk -F': ' '{print $2}')
        PASS_LAST_CHANGE=$(echo "$CHAGE_INFO" | grep "Last password change" | awk -F': ' '{print $2}')
        PASS_EXPIRES=$(echo "$CHAGE_INFO" | grep "Password expires" | awk -F': ' '{print $2}')

        if echo "$CHAGE_INFO" | grep -q "Account expires\|Password expires"; then
          if echo "$CHAGE_INFO" | grep "Account expires" | grep -q "never"; then
            : # Account never expires
          else
            ACCOUNT_EXPIRE_DATE=$(echo "$CHAGE_INFO" | grep "Account expires" | awk -F': ' '{print $2}')
            if [ "$(date +%s)" -gt "$(date -d "$ACCOUNT_EXPIRE_DATE" +%s)" ]; then
              ACCOUNT_STATUS="Expired"
            fi
          fi
        fi

        if [ "$LAST_LOGIN" != "N/A" ] && [ -n "$LAST_LOGIN" ]; then
          LAST_LOGIN_SECONDS=$(date -d "$LAST_LOGIN" +%s)
          CURRENT_SECONDS=$(date +%s)
          INACTIVE_THRESHOLD_DAYS=90 # Define inactive threshold
          INACTIVE_THRESHOLD_SECONDS=$((INACTIVE_THRESHOLD_DAYS * 24 * 60 * 60))

          if [ $((CURRENT_SECONDS - LAST_LOGIN_SECONDS)) -gt "$INACTIVE_THRESHOLD_SECONDS" ]; then
            ACCOUNT_STATUS="Inactive (>$INACTIVE_THRESHOLD_DAYS days)"
          fi
        fi
      fi
      USER_DATA+="$ACCOUNT_STATUS:$LAST_LOGIN:$PASS_LAST_CHANGE:$PASS_EXPIRES:"

      # Check for SSH keys
      SSH_KEYS_FOUND="No"
      if [ -d "$home_dir/.ssh" ] && ls "$home_dir/.ssh"/*.pub &>/dev/null; then
        SSH_KEYS_FOUND="Yes"
      fi
      USER_DATA+="$SSH_KEYS_FOUND\n"
    fi
  done < /etc/passwd

  echo "$USER_DATA" > /tmp/uaat_user_data.tmp

}




generate_csv_report() {
  echo "Generating CSV report: ${REPORT_FILE}"
  echo "Username,UID,GID,Home Directory,Shell,Sudo Access,Account Status,Last Login,Password Last Changed,Password Expires,SSH Keys Found" > "${REPORT_FILE}"
  sed 's/:/,/g' /tmp/uaat_user_data.tmp >> "${REPORT_FILE}"
  rm /tmp/uaat_user_data.tmp

}

# Function to send email report
send_email_report() {
  echo "Sending email report to ${SECURITY_EMAIL}"
  if [ -f "${REPORT_FILE}" ]; then
    echo "Subject: UAAT Report - $(date +%Y-%m-%d)" | cat - "${REPORT_FILE}" | sendmail "${SECURITY_EMAIL}"
    echo "Report sent to ${SECURITY_EMAIL}"
  else
    echo "Error: Report file ${REPORT_FILE} not found. Email not sent."
  fi

}

# Main execution
main() {
  audit_users_and_groups
  generate_csv_report
  send_email_report
  echo "UAAT audit complete."
}

main




# Sudo/Root Access Detection Plan:
# - Check /etc/passwd for UID 0 (root).
# - Check /etc/group for 'sudo' or 'wheel' group members.
# - Use 'sudo -l -U <username>' to check specific user sudo privileges (requires root privileges to run the script).




# Expired/Inactive Accounts Detection Plan:
# - Use 'chage -l <username>' to check password expiry and last login dates.
# - Define 'inactive' based on a threshold (e.g., no login in X days).




# CSV Report Format Plan:
# - Header row: Username,UID,GID,Home Directory,Shell,Account Status,Last Login,Password Last Changed,Password Expires,Sudo Access,SSH Keys Found
# - Each user will be a row.


