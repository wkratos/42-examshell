#!/usr/bin/env bash

set -u
file="../../rendu/$2/$1"
reference=$1
shift 2
traceback=traceback

rm -f .system/grading/traceback
cd .system/grading || exit 1
rm -f source final sourcexam finalexam .dev

if ! cc -Wall -Wextra -Werror "$reference" main.c -o source 2>.dev; then
    printf 'Internal reference compilation failed.\n' >"$traceback"
    cat .dev >>"$traceback"
    exit 1
fi
timeout --kill-after=1s 3s ./source "$@" | cat -e >sourcexam
reference_status=${PIPESTATUS[0]}
rm -f source

if [ ! -f "$file" ] || ! cc -Wall -Wextra -Werror "$file" main.c -o final 2>.dev; then
    printf 'COMPILATION ERROR or missing submission: %s\n' "$file" >"$traceback"
    cat .dev >>"$traceback"
    rm -f sourcexam final .dev
    exit 1
fi
timeout --kill-after=1s 3s ./final "$@" | cat -e >finalexam
submission_status=${PIPESTATUS[0]}

if [ "$submission_status" -eq 124 ] || [ "$submission_status" -eq 137 ]; then
    printf 'TIMEOUT: submission exceeded 3 seconds.\n' >"$traceback"
elif [ "$reference_status" -ne "$submission_status" ] || ! cmp -s sourcexam finalexam; then
    printf 'WRONG OUTPUT\nExpected:\n' >"$traceback"
    cat sourcexam >>"$traceback"
    printf '\nReceived:\n' >>"$traceback"
    cat finalexam >>"$traceback"
fi
rm -f source final sourcexam finalexam .dev
cd ../.. || exit 1
