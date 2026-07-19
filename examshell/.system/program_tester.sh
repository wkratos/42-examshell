#!/usr/bin/env bash

# Shared deterministic tester for program exercises.  The reference source and this
# metadata live only in .system/grading; submissions are read from rendu.
set -u
if ! command -v timeout >/dev/null 2>&1; then
    printf 'Error: GNU timeout is required for grading.\n' >&2
    exit 1
fi
name=$(cat .system/grading/exercise_name)
file="$name.c"
reference=".system/grading/$file"
submission="rendu/$name/$file"
traceback=.system/grading/traceback
passed=.system/grading/passed
rm -f "$traceback" "$passed" .system/grading/reference .system/grading/submission

if ! cc -Wall -Wextra -Werror "$reference" -o .system/grading/reference 2>"$traceback"; then
    exit 1
fi
if [ ! -f "$submission" ] || ! cc -Wall -Wextra -Werror "$submission" -o .system/grading/submission 2>>"$traceback"; then
    printf 'Missing %s or compilation failed.\n' "$submission" >>"$traceback"
    exit 1
fi

run_case() {
    expected=$(mktemp)
    actual=$(mktemp)
    timeout 3 .system/grading/reference "$@" >"$expected" 2>&1
    ref_status=$?
    timeout --kill-after=1s 3s .system/grading/submission "$@" >"$actual" 2>&1
    sub_status=$?
    if [ "$ref_status" -ne "$sub_status" ] || ! cmp -s "$expected" "$actual"; then
        printf 'FAILED: %s' "$file" >>"$traceback"
        printf ' <%s>' "$@" >>"$traceback"
        printf '\nExpected:\n' >>"$traceback"
        cat "$expected" >>"$traceback"
        printf '\nReceived:\n' >>"$traceback"
        cat "$actual" >>"$traceback"
        rm -f "$expected" "$actual"
        return 1
    fi
    rm -f "$expected" "$actual"
}

ok=0
case "$name" in
    add_prime_sum) run_case 1 && run_case 2 && run_case 5 && run_case 100 || ok=1 ;;
    epur_str) run_case 'one' && run_case '  lorem   ipsum  ' && run_case $'\talpha\tbeta\t' && run_case $'  mixed\t spaces \t' && run_case '' && run_case || ok=1 ;;
    expand_str) run_case '  lorem   ipsum  ' && run_case 'one' && run_case || ok=1 ;;
    paramsum) run_case && run_case a && run_case a b c d e || ok=1 ;;
    rstr_capitalizer) run_case 'a FiRSt LiTTlE TESt' && run_case ' SecONd test ' || ok=1 ;;
    fprime) run_case 1 && run_case 42 && run_case 225225 && run_case 7919 || ok=1 ;;
    rostring) run_case 'abc' && run_case '   lorem ipsum dolor' && run_case || ok=1 ;;
    str_capitalizer) run_case 'a FiRSt LiTTlE TESt' && run_case ' SecONd test ' || ok=1 ;;
    tab_mult) run_case 0 && run_case 7 && run_case 19 && run_case abc || ok=1 ;;
    *) printf 'No test cases configured for %s.\n' "$name" >>"$traceback"; ok=1 ;;
esac

rm -f .system/grading/reference .system/grading/submission
if [ "$ok" -eq 0 ]; then
    touch "$passed"
    rm -f "$traceback"
else
    mv "$traceback" traceback 2>/dev/null || true
fi
exit "$ok"
