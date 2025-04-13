#!/bin/bash

# Generate the date and time in a filename-friendly format (e.g., 20250412_133210)
DATE_TIME=$(date '+%Y-%m-%d_%H')

echo "Creating logs directory"
mkdir -p ~/logs

# Set the log file path with the dynamic date and time
export ANSIBLE_LOG_PATH="~/logs/ansible_${DATE_TIME}.log"


# Check if any arguments were passed
if [ $# -eq 0 ]; then
  echo "Error: No playbook specified. Please provide the playbook path."
  echo "Usage: ./run_playbook.sh <playbook.yml>"
  exit 1
fi

# Run the Ansible playbook
ansible-playbook "$@"