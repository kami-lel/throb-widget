#!/usr/bin/env bash

################################################################################
# throb-widget-demo.sh
#
# demo of throb-widget.sh, runs the throb animation for 5 seconds
################################################################################


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Step 1: source the library
source "${SCRIPT_DIR}/throb-widget.sh"

echo "Mocking Connecting Remote Server:"

printf "Connecting"
# Step 2: start throb, on stderr
throb_widget_start

sleep 5  # stand-in for the wrapped work

# Step 3: stop throb, return cursor to Column 0
throb_widget_stop

printf "\nFinished Mocking Connection after 5 second\n"
