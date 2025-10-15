#!/bin/bash
# Fake Engagement Cron Job
# This script should be run every minute via cron
#
# Add to crontab:
# * * * * * /path/to/edd/scripts/fake-engagement-cron.sh >> /var/log/fake-engagement.log 2>&1

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

# Run the fake engagement generator
php api/live/fake-engagement.php

# Exit with the PHP script's exit code
exit $?
