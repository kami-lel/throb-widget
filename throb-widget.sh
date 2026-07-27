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
THROB_IDX=${THROB_IDX:-0}  # cur frame idx, persists across calls
_throb_pid=""  # pid of the background throb loop, empty means not running

# private methods  #############################################################
is_utf8_locale() {
    local loc="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
    [[ "$loc" == *UTF-8* || "$loc" == *utf8* ]]
}

# Public API  ###################################################################
get_throb_frame() {
    local -a frames

    if is_utf8_locale; then
        frames=("${FRAMES_PULSE[@]}")
    else
        frames=("${FRAMES_PULSE_ASCII[@]}")
    fi

    printf '%s' "${frames[THROB_IDX]}"
    THROB_IDX=$(( (THROB_IDX + 1) % ${#frames[@]} ))
}

start_throb() {  # -----------------------------------------------------------
    local interval="${1:-0.1}"

    if [[ -n "${_throb_pid}" ]]; then
        return  # throb already running
    fi

    (
        while true; do
            printf '\r'
            get_throb_frame
            sleep "${interval}"
        done
    ) >&2 &
    _throb_pid=$!
}

stop_throb() {  # ------------------------------------------------------------
    if [[ -z "${_throb_pid}" ]]; then
        return  # no throb running
    fi

    kill "${_throb_pid}" 2>/dev/null || true
    wait "${_throb_pid}" 2>/dev/null || true
    printf '\r' >&2
    _throb_pid=""
}
