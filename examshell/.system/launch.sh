#!/usr/bin/env bash

set -u

cd "$(dirname "$0")/.." || exit 1

for command in g++ cc timeout; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Error: required command "%s" is not installed.\n' "$command" >&2
        exit 1
    fi
done

if ! printf '#include <readline/readline.h>\nint main(void){return 0;}\n' |
    g++ -x c++ - -lreadline -o .system/readline_ok 2>.system/.devmake.err; then
    printf 'Error: the readline development library is required.\n' >&2
    cat .system/.devmake.err >&2
    rm -f .system/readline_ok
    exit 1
fi
rm -f .system/readline_ok .system/.devmake.err

sources=(
    .system/exercise.cpp .system/main.cpp .system/menu.cpp .system/exam.cpp
    .system/utils.cpp .system/grade_request.cpp .system/data_persistence.cpp
)

if ! g++ -std=c++11 -Wall -Wextra -Werror "${sources[@]}" -lreadline -o .system/a.out; then
    printf 'Error: examshell compilation failed.\n' >&2
    exit 1
fi

printf 'Build complete: .system/a.out\n'
if [ "${1:-run}" = run ]; then
    exec .system/a.out
fi
