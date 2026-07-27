#!/usr/bin/env bash

################################################################################
# throb-widget-demo.sh
#
# demo of throb-widget.sh, runs the throb animation for 5 seconds
################################################################################


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/throb-widget.sh"  # step 1: source the library

echo "The Program is Currently Running:"

throb_widget_start 0.15  # step 2: start throb, 0.15s per frame, on stderr
sleep 5  # stand-in for the wrapped work
throb_widget_stop  # step 3: stop throb, rtn cursor to Column 0
