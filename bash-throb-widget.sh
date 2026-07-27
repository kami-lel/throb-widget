#!/usr/bin/env bash
# bash-throb-widget.sh
#
# single-character pulsing animation, source this file or copy it inline
# TODO use CB

FRAMES_PULSE=('░' '▒' '▓' '█' '▓' '▒')
FRAMES_PULSE_ASCII=('.' 'o' 'O' '@' 'O' 'o')

THROB_IDX=${THROB_IDX:-0}  # cur frame idx, persists across calls

is_utf8_locale() {
    local loc="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
    [[ "$loc" == *UTF-8* || "$loc" == *utf8* ]]
}

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
