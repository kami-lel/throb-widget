#!/usr/bin/env bash
# throb-widget-demo.sh
#
# demo of throb-widget.sh, runs the throb animation for 10 seconds

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/throb-widget.sh"

echo "The Program is Currently Running:"

start_throb 0.15
sleep 10
stop_throb
