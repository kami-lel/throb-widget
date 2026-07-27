#!/usr/bin/env bash

################################################################################
# throb-widget.sh v1.0.0
#
# single-character pulsing animation, source this file or copy it inline<
# q.v. https://github.com/kami-lel/bash-throb-widget
################################################################################


# constants  ===================================================================
THROB_WIDGET_FRAMES_PULSE=('░' '▒' '▓' '█' '▓' '▒')
THROB_WIDGET_FRAMES_PULSE_ASCII=('.' 'o' 'O' '@' 'O' 'o')


# private variables  ===========================================================
throb_widget_idx=${throb_widget_idx:-0}  # BUG comment claims this persists across calls, but the increment runs inside the forked subshell so the caller's copy never changes
throb_widget_pid=""  # BUG unconditional reset drops a running pid when re-sourced, then throb_widget_stop no-ops while the loop keeps animating


# private methods  =============================================================
# FIXME throb_widget_is_utf8_locale and throb_widget_get_frame share the throb_widget_ prefix with the Public API, making them indistinguishable to a Caller reading the sourced namespace

# throb_widget_is_utf8_locale()
#
# succeed when the locale is UTF-8, which selects the Unicode frame set
#
# RETURN:
#   0  locale is UTF-8, caller should use THROB_WIDGET_FRAMES_PULSE
#   1  locale is not UTF-8, caller should use THROB_WIDGET_FRAMES_PULSE_ASCII
throb_widget_is_utf8_locale() {
    local loc="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
    [[ "${loc}" == *UTF-8* || "${loc}" == *utf8* ]]
}

# throb_widget_get_frame()
#
# print the current frame, one character with no newline, then advance
#
# picks THROB_WIDGET_FRAMES_PULSE or THROB_WIDGET_FRAMES_PULSE_ASCII via
# throb_widget_is_utf8_locale, every call
#
# OUTPUT:
#   one frame character to stdout, no trailing newline
throb_widget_get_frame() {
    local -a frames

    if throb_widget_is_utf8_locale; then
        frames=("${THROB_WIDGET_FRAMES_PULSE[@]}")
    else
        frames=("${THROB_WIDGET_FRAMES_PULSE_ASCII[@]}")
    fi

    printf '%s' "${frames[throb_widget_idx]}"
    throb_widget_idx=$(( (throb_widget_idx + 1) % ${#frames[@]} ))
    return 0
}

# Public API  ==================================================================

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
# draws inline: the first frame lands wherever the caller's cursor already is,
# and every frame after backs up one column first, so only that one column
# is ever touched, no matter what the caller printed before it
#
# USAGE:
#   throb_widget_start [INTERVAL]
#
# ARGUMENT:
#   [INTERVAL]  seconds between frames, default 0.1
#
# OUTPUT:
#   one frame character to stderr every INTERVAL seconds, each preceded by a
#   backspace but the first, until throb_widget_stop runs or the caller's
#   process exits
throb_widget_start() {  # ------------------------------------------------------
    local interval="${1:-0.2}"

    if [[ -n "${throb_widget_pid}" ]]; then
        return 0  # throb already running
    fi

    local owner="${BASHPID:-$$}"  # caller's process, the loop's lifetime bound

    (
        # BUG no trap on EXIT/INT/TERM anywhere in this file, so a caller that exits without calling throb_widget_stop leaves this loop orphaned and reparented to init
        # stop as soon as the owner is gone, no trap needed on either side
        local first_frame=1
        while kill -0 "${owner}" 2>/dev/null; do
            if (( ! first_frame )); then
                printf '\b'  # back up onto the previous frame's column, nothing else on the line is touched
            fi
            first_frame=0
            throb_widget_get_frame
            sleep "${interval}"
        done
    ) >&2 &  # BUG frames land in redirected/non-terminal stderr as raw control bytes, and this fork also prints an unsuppressed job-control notice when sourced into an interactive shell
    throb_widget_pid=$!
    return 0
}

# throb_widget_stop()
#
# stop the throb and erase its last drawn frame
#
# does nothing when no throb is running. the cursor is left exactly where the
# frame was drawn, now blank, so the caller's next write picks up right there
#
# USAGE:
#   throb_widget_stop
#
# OUTPUT:
#   a backspace, a space, then a backspace, to stderr
throb_widget_stop() {  # -------------------------------------------------------
    if [[ -z "${throb_widget_pid}" ]]; then
        return 0  # no throb running
    fi

    kill "${throb_widget_pid}" 2>/dev/null || true
    wait "${throb_widget_pid}" 2>/dev/null || true
    printf '\b \b' >&2  # back onto the frame column, blank it, then back up again so the cursor rests there
    throb_widget_pid=""
    return 0
}



# END of throb-widget.sh  ######################################################