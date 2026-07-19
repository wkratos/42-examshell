# examshell

Interactive local practice for 42 Piscine exercises and the existing Student Exam Rank
exercises.

Original project by [@jcluzet].

Maintained, expanded, and improved by [@wkratos](https://github.com/wkratos).

## Modes

- **Piscine mode:** Weeks 01, 02, 03, and Week 04 Final.
- **Student mode:** the existing Exam Rank 02–06 content and its original behavior.

Piscine Weeks 01–03 award 10 points for each successful correction. Week 04 awards
6 points per success and caps the displayed final score at 100. Exercises are selected
randomly inside the current available difficulty pool and are not repeated during a
session. Weeks 01 and 02 reuse their eight physical difficulty pools across ten scoring
steps instead of attempting to open nonexistent directories.

## Dependencies

- Linux or macOS with a POSIX-compatible shell;
- `g++` and `cc`;
- the readline development library;
- GNU `timeout` (commonly provided by GNU coreutils).

The launcher reports the exact missing dependency or compiler error. It does not install
packages or update the repository automatically.

## Build and run

```sh
cd examshell
make
```

The first `make` compiles and starts the interface. Other build targets are:

```sh
make clean
make fclean
make re
```

Subjects are written to `subjects/`. Put the requested submission in
`rendu/<exercise-name>/`, then enter `grademe` in the examshell terminal.

## Grading safety

Only exercise folders containing a subject and a meaningful tester are selectable.
The shared correction engine applies a 30-second hard timeout to every tester; newer
program testers additionally apply a three-second timeout to each submitted execution.
Compilation failures, missing submissions, wrong output, and timeouts are failures.

The current Piscine placement audit is recorded in [TESTER_STATUS.md](TESTER_STATUS.md).
That matrix includes intentionally excluded incomplete Week 03 placements.

## Known limitations

- This is an independent practice simulator, not an official 42 product.
- Subjects and expected behavior can differ between campuses or change over time.
- Many historical testers compare output with bundled internal fixtures. Passing them is
  useful practice but does not guarantee a result from an official Moulinette.
- The global timeout reports which grading request timed out, but legacy testers do not
  always identify the individual test case that stalled.
- Leak checking is not implemented for every exercise.

## Reporting a tester problem

Open an issue at [github.com/wkratos/42-examshell](https://github.com/wkratos/42-examshell)
and include the week, difficulty, exercise, submitted filename, observed output,
expected output, operating system, and compiler version. Do not include exam answers or
private credentials.

See [AUTHORS.md](AUTHORS.md) for attribution and maintenance details.
