#!/usr/bin/env bash

################################################################################
# throb-widget.sh
#
# single-character pulsing animation, source this file or copy it inline
################################################################################

# TODO add version & github link


# constants  ###################################################################
# BUG unprefixed globals collide w/ any Caller Variable of the same name, unlike every other name in this file
FRAMES_PULSE=('░' '▒' '▓' '█' '▓' '▒')
FRAMES_PULSE_ASCII=('.' 'o' 'O' '@' 'O' 'o')


# private variables  ###########################################################
_throb_widget_idx=${_throb_widget_idx:-0}  # BUG comment claims this persists across calls, but the increment runs inside the forked subshell so the caller's copy never changes
_throb_widget_pid=""  # BUG unconditional reset drops a running pid when re-sourced, then throb_widget_stop no-ops while the loop keeps animating


# private methods  #############################################################
# FIXME throb_widget_is_utf8_locale and throb_widget_get_frame share the throb_widget_ prefix with the Public API, making them indistinguishable to a Caller reading the sourced namespace

# throb_widget_is_utf8_locale()
#
# succeed when the locale is UTF-8, which selects the Unicode frame set
#
# RETURN:
#   0  locale is UTF-8, caller should use FRAMES_PULSE
#   1  locale is not UTF-8, caller should use FRAMES_PULSE_ASCII
throb_widget_is_utf8_locale() {
    local loc="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
    [[ "${loc}" == *UTF-8* || "${loc}" == *utf8* ]]
}

# throb_widget_get_frame()
#
# print the current frame, one character with no newline, then advance
#
# picks FRAMES_PULSE or FRAMES_PULSE_ASCII via throb_widget_is_utf8_locale,
# every call
#
# OUTPUT:
#   one frame character to stdout, no trailing newline
throb_widget_get_frame() {
    local -a frames

    if throb_widget_is_utf8_locale; then
        frames=("${FRAMES_PULSE[@]}")
    else
        frames=("${FRAMES_PULSE_ASCII[@]}")
    fi

    printf '%s' "${frames[_throb_widget_idx]}"
    _throb_widget_idx=$(( (_throb_widget_idx + 1) % ${#frames[@]} ))
    return 0
}

# Public API  ##################################################################

# throb_widget_start()
#
# start the throb, drawing one frame per interval on stderr
#
# the interval reaches sleep unvalidated, so the caller owns its correctness.
# a positive number is required — zero and non-numeric values both leave the
# loop with no pause, which spins the processor and floods stderr. fractional
# values such as the default depend on GNU coreutils sleep
#
# calling this while a throb already runs does nothing. the loop also ends on
# its own once the caller's process is gone, so a missing stop leaks no process
#
# USAGE:
#   throb_widget_start [INTERVAL]
#
# ARGUMENT:
#   [INTERVAL]  seconds between frames, default 0.1
#
# OUTPUT:
#   one frame plus a leading carriage return to stderr, every INTERVAL
#   seconds, until throb_widget_stop runs or the caller's process exits
throb_widget_start() {  # ------------------------------------------------------
    local interval="${1:-0.1}"  # BUG no validation, a non-numeric value makes sleep exit immediately and turns the loop into a busy loop flooding stderr

    if [[ -n "${_throb_widget_pid}" ]]; then
        return 0  # throb already running
    fi

    local owner="${BASHPID:-$$}"  # caller's process, the loop's lifetime bound

    (
        # BUG no trap on EXIT/INT/TERM anywhere in this file, so a caller that exits without calling throb_widget_stop leaves this loop orphaned and reparented to init
        # stop as soon as the owner is gone, no trap needed on either side
        while kill -0 "${owner}" 2>/dev/null; do
            printf '\r'  # BUG returns cursor to column 0 and overwrites the first character of whatever the caller already printed, breaking the inline-splice promise
            throb_widget_get_frame
            sleep "${interval}"
        done
    ) >&2 &  # BUG frames land in redirected/non-terminal stderr as raw control bytes, and this fork also prints an unsuppressed job-control notice when sourced into an interactive shell
    _throb_widget_pid=$!
    return 0
}

# throb_widget_stop()
#
# stop the throb and return the cursor to column 0
#
# does nothing when no throb is running. the last frame drawn stays on screen,
# the caller's next write to that column covers it
#
# USAGE:
#   throb_widget_stop
#
# OUTPUT:
#   a carriage return to stderr
throb_widget_stop() {  # -------------------------------------------------------
    if [[ -z "${_throb_widget_pid}" ]]; then
        return 0  # no throb running
    fi

    kill "${_throb_widget_pid}" 2>/dev/null || true
    wait "${_throb_widget_pid}" 2>/dev/null || true
    printf '\r' >&2  # BUG repositions the cursor but erases nothing, so the last frame drawn stays on screen until unrelated output happens to cover column 0
    _throb_widget_pid=""
    return 0
}
