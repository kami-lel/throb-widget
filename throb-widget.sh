#!/usr/bin/env bash
#
################################################################################
# throb-widget.sh
#
# single-character pulsing animation, source this file or copy it inline
################################################################################


# constants  ###################################################################
FRAMES_PULSE=('░' '▒' '▓' '█' '▓' '▒')
FRAMES_PULSE_ASCII=('.' 'o' 'O' '@' 'O' 'o')


# private variables  ###########################################################
_throb_widget_idx=${_throb_widget_idx:-0}  # frame idx, private to the subshell
_throb_widget_pid=""  # pid of the throb loop, empty means not running


# private methods  #############################################################

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
    local interval="${1:-0.1}"

    if [[ -n "${_throb_widget_pid}" ]]; then
        return 0  # throb already running
    fi

    local owner="${BASHPID:-$$}"  # caller's process, the loop's lifetime bound

    (
        # stop as soon as the owner is gone, no trap needed on either side
        while kill -0 "${owner}" 2>/dev/null; do
            printf '\r'
            throb_widget_get_frame
            sleep "${interval}"
        done
    ) >&2 &
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
    printf '\r' >&2
    _throb_widget_pid=""
    return 0
}
