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
    compile_error) printf 'this is not valid C\n' >"$work/rendu/$name/$submitted" ;;
    missing) ;;
    infinite)
        if grep -Eq '(^|[[:space:]])main[[:space:]]*\(' "$reference"; then
            printf 'int main(void){for(;;){} return 0;}\n' >"$work/rendu/$name/$submitted"
        else
            cp "$reference" "$work/rendu/$name/$submitted"
            sed -i '0,/^[[:space:]]*{$/s//&\n\tfor (;;) {}/' "$work/rendu/$name/$submitted"
        fi
        ;;
    semantic)
        if [ "$name" = is_power_of_2 ]; then
            printf '%s\n' 'int is_power_of_2(unsigned int n){return n != 0 && n % 2 == 0;}' >"$work/rendu/$name/$submitted"
        elif [ "$name" = ft_strlen ]; then
            printf '%s\n' 'int ft_strlen(char *s){(void)s;return 0;}' >"$work/rendu/$name/$submitted"
        elif [ "$name" = swap_bits ]; then
            printf '%s\n' 'unsigned char swap_bits(unsigned char n){return n;}' >"$work/rendu/$name/$submitted"
        elif [ "$name" = reverse_bits ]; then
            printf '%s\n' 'unsigned char reverse_bits(unsigned char n){return n;}' >"$work/rendu/$name/$submitted"
        elif [ "$name" = ft_atoi ]; then
            printf '%s\n' 'int ft_atoi(char *s){(void)s;return 0;}' >"$work/rendu/$name/$submitted"
        elif [ "$name" = ft_strdup ]; then
            printf '%s\n' 'char *ft_strdup(char *s){return s;}' >"$work/rendu/$name/$submitted"
        elif grep -Eq '(^|[[:space:]])main[[:space:]]*\(' "$reference"; then
            printf '%s\n' '#include <unistd.h>' 'int main(void){write(1,"\n",1);return 0;}' >"$work/rendu/$name/$submitted"
        elif [ "$name" = ft_swap ]; then
            printf '%s\n' 'void ft_swap(int *a,int *b){(void)a;(void)b;}' >"$work/rendu/$name/$submitted"
        else
            cp "$reference" "$work/rendu/$name/$submitted"
            if grep -q 'while (' "$reference"; then
                sed -i '0,/while (/s//while (0 \&\& /' "$work/rendu/$name/$submitted"
            elif grep -q 'if (' "$reference"; then
                sed -i '0,/if (/s//if (0 \&\& /' "$work/rendu/$name/$submitted"
            else
                printf 'No safe semantic mutation for %s.\n' "$name" >&2
                exit 3
            fi
        fi
        ;;
    *) exit 2 ;;
esac

set +e
(cd "$work" && timeout --kill-after=2s 35s bash .system/grading/tester.sh >/dev/null 2>&1)
tester_status=$?
set -e
if [ "$mode" = semantic ] && grep -Eqi 'compilation|undefined reference|error:' "$work/traceback" "$work/.system/grading/traceback" 2>/dev/null; then
    exit 4
fi
if [ "$tester_status" -eq 0 ] && [ -f "$work/.system/grading/passed" ]; then
    exit 0
fi
exit 1
