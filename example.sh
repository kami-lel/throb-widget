#!/usr/bin/env bash
# example.sh
#
# demo of bash-throb-widget.sh, runs the throb animation indefinitely

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/bash-throb-widget.sh"

echo "The Program is Currently Running:"

while true; do
    printf '\r'
    get_throb_frame
    sleep 0.15
done
