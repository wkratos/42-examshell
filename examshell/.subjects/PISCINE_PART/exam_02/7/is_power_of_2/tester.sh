#!/usr/bin/env bash

set -u
name=is_power_of_2
file=is_power_of_2.c
FILE='is_power_of_2.c'
ASSIGN='is_power_of_2/is_power_of_2.c'
reference=.system/grading/$file
submission=rendu/$name/$file
main=.system/grading/main.c
traceback=traceback
rm -f .system/grading/passed .system/grading/reference .system/grading/submission "$traceback"

if [ ! -f "$submission" ]; then
    printf 'Missing submission: %s\n' "$submission" >"$traceback"
    exit 1
fi
if ! cc -Wall -Wextra -Werror "$reference" "$main" -o .system/grading/reference 2>"$traceback"; then
    exit 1
fi
if ! cc -Wall -Wextra -Werror "$submission" "$main" -o .system/grading/submission 2>"$traceback"; then
    exit 1
fi

for value in 0 1 2 3 4 6 8 10 16 18 31 32 1024 1023; do
    expected=$(timeout --kill-after=1s 3s .system/grading/reference "$value")
    reference_status=$?
    actual=$(timeout --kill-after=1s 3s .system/grading/submission "$value")
    submission_status=$?
    if [ "$submission_status" -eq 124 ] || [ "$submission_status" -eq 137 ]; then
        printf 'TIMEOUT for input %s.\n' "$value" >"$traceback"
        rm -f .system/grading/reference .system/grading/submission
        exit 1
    fi
    if [ "$reference_status" -ne "$submission_status" ] || [ "$expected" != "$actual" ]; then
        printf 'FAILED input %s: expected %s, received %s.\n' "$value" "$expected" "$actual" >"$traceback"
        rm -f .system/grading/reference .system/grading/submission
        exit 1
    fi
done
rm -f .system/grading/reference .system/grading/submission "$traceback"
touch .system/grading/passed
