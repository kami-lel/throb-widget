#!/usr/bin/env bash
#
################################################################################
# throb-widget.sh
#
# single-character pulsing animation, source this file or copy it inline
################################################################################



# FIXME rewrite w/ copy & paste

# constants  ###################################################################
FRAMES_PULSE=('░' '▒' '▓' '█' '▓' '▒')
FRAMES_PULSE_ASCII=('.' 'o' 'O' '@' 'O' 'o')

# private variables  ###########################################################
_throb_widget_idx=${_throb_widget_idx:-0}  # cur frame idx, persists across calls
_throb_widget_pid=""  # pid of the background throb loop, empty means not running

# private methods  #############################################################
throb_widget_is_utf8_locale() {
    local loc="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
    [[ "$loc" == *UTF-8* || "$loc" == *utf8* ]]
}

throb_widget_get_frame() {
    local -a frames

    if throb_widget_is_utf8_locale; then
        frames=("${FRAMES_PULSE[@]}")
    else
        frames=("${FRAMES_PULSE_ASCII[@]}")
    fi

    printf '%s' "${frames[_throb_widget_idx]}"
    _throb_widget_idx=$(( (_throb_widget_idx + 1) % ${#frames[@]} ))
}

# Public API  ###################################################################
throb_widget_start() {  # -----------------------------------------------------
    local interval="${1:-0.1}"

    if [[ -n "${_throb_widget_pid}" ]]; then
        return  # throb already running
    fi

    (
        while true; do
            printf '\r'
            throb_widget_get_frame
            sleep "${interval}"
        done
    ) >&2 &
    _throb_widget_pid=$!
}

throb_widget_stop() {  # ------------------------------------------------------
    if [[ -z "${_throb_widget_pid}" ]]; then
        return  # no throb running
    fi

    kill "${_throb_widget_pid}" 2>/dev/null || true
    wait "${_throb_widget_pid}" 2>/dev/null || true
    printf '\r' >&2
    _throb_widget_pid=""
}
