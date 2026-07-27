#!/usr/bin/env bash
# throb-widget-demo.sh
#
# demo of throb-widget.sh, runs the throb animation for 10 seconds


# FIXME rewrite demo w/ better comments

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/throb-widget.sh"

echo "The Program is Currently Running:"

throb_widget_start 0.15
sleep 10
throb_widget_stop
