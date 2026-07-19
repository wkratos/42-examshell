#!/usr/bin/env bash

# Isolated regression probe for Piscine tester placements.
set -u

repo=$(cd "$(dirname "$0")/.." && pwd)
exercise=${1:?exercise directory required}
mode=${2:?correct, wrong, or missing required}
name=$(basename "$exercise")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT INT TERM

mkdir -p "$work/.system/grading" "$work/rendu/$name"
cp "$repo/.system/"auto_correc_*.sh "$work/.system/" 2>/dev/null || true
cp "$repo/.system/program_tester.sh" "$work/.system/"
find "$exercise" -maxdepth 1 -type f -exec cp {} "$work/.system/grading/" \;

assign=$(sed -n "s/^ASSIGN=['\"]\([^'\"]*\)['\"].*/\1/p" "$exercise/tester.sh" | head -1)
if [ -z "$assign" ] && [ -f "$exercise/exercise_name" ]; then
    assign="$name/$name.c"
fi
if [ -z "$assign" ]; then
    printf 'unsupported-path\n'
    exit 2
fi
submitted=$(basename "$assign")
if [[ "$submitted" != *.* ]]; then
    submitted=$(sed -n "s/^FILE=['\"]\([^'\"]*\)['\"].*/\1/p" "$exercise/tester.sh" | head -1)
fi
reference="$exercise/$submitted"
if [ ! -f "$reference" ]; then
    reference=$(find "$exercise" -maxdepth 1 -type f -name '*.c' ! -name main.c ! -name '*withmain.c' | head -1)
fi

case "$mode" in
    correct) [ -n "$reference" ] && cp "$reference" "$work/rendu/$name/$submitted" ;;
    wrong) printf 'int main(void){return 0;}\n' >"$work/rendu/$name/$submitted" ;;
    missing) ;;
    infinite) printf 'int main(void){for(;;){} return 0;}\n' >"$work/rendu/$name/$submitted" ;;
    *) exit 2 ;;
esac

if (cd "$work" && timeout --foreground --kill-after=2s 35s bash .system/grading/tester.sh >/dev/null 2>&1); then
    [ -f "$work/.system/grading/passed" ]
else
    exit 1
fi
