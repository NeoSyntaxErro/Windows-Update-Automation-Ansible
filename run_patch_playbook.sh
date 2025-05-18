#!/bin/bash

# Script: setup.sh
# Description: Sets up a cron job to execute an Ansible playbook for Windows patch management every Sunday at 11:30 PM
# Author: Steffen Teall
# Date: 2025-05-18

# Check for required arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <path_to_playbook.yml> <path_to_inventory.ini>"
  exit 1
fi

PLAYBOOK_PATH=$(realpath "$1")
INVENTORY_PATH=$(realpath "$2")

# Validate playbook file
if [[ ! -f "$PLAYBOOK_PATH" ]]; then
  echo "Error: Playbook not found at '$PLAYBOOK_PATH'"
  exit 1
fi

# Validate inventory file
if [[ ! -f "$INVENTORY_PATH" ]]; then
  echo "Error: Inventory file not found at '$INVENTORY_PATH'"
  exit 1
fi

# Absolute path to ansible-playbook
ANSIBLE_PLAYBOOK_BIN=$(command -v ansible-playbook)
if [[ -z "$ANSIBLE_PLAYBOOK_BIN" ]]; then
  echo "Error: ansible-playbook not found. Please install Ansible."
  exit 1
fi

# Log directory
LOG_DIR="$HOME/ansible-patch-logs"
mkdir -p "$LOG_DIR"

# Cron job command
CRON_CMD="30 23 * * 0 $ANSIBLE_PLAYBOOK_BIN -i '$INVENTORY_PATH' '$PLAYBOOK_PATH' >> '$LOG_DIR/patch_run.log' 2>&1"

# Remove any previous job matching this playbook path
( crontab -l 2>/dev/null | grep -v "$PLAYBOOK_PATH" ; echo "$CRON_CMD" ) | crontab -

echo "✅ Cron job scheduled to run the playbook every Sunday at 11:30 PM."
echo "📝 Logs will be stored in: $LOG_DIR/patch_run.log"
