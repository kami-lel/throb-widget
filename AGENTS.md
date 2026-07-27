---
name: bash-throb-widget AGENTS
alwaysApply: true
---

# bash-throb-widget AGENTS

## Project Overview & Pointers

*bash-throb-widget* is a single-file bash utility exposing a single-character
pulsing animation ("throb") that a calling program uses to signal it is
alive. See [CONTEXT.md](CONTEXT.md) for the design constraints behind the
single-file, dual-usage requirement.

## Code Style

- keep the entire utility inside [bash-throb-widget.sh](bash-throb-widget.sh) — the script must remain valid both when *sourced* and when its contents are *pasted verbatim* into a caller script, so avoid `set -e`, `exit`, or anything that would alter a caller's shell options or terminate a caller's process
- each animation frame must be a single character — do not widen `FRAMES_PULSE` or `FRAMES_PULSE_ASCII` to multi-character frames
- keep the Unicode frame set (`FRAMES_PULSE`) and the ASCII fallback (`FRAMES_PULSE_ASCII`) in sync — same frame count, same pulse shape

## Testing Instructions

- no test suite exists yet; verify changes by sourcing the script in a bash shell and exercising the throb function/frames manually
- when a test framework is introduced, record the run command here

## PR & Commit Instructions

- keep [CHANGELOG.md](CHANGELOG.md) `[Unreleased]` section current with any behavioral change

## Documentation Maintenance

- update this file when setup/behavioral rules change, and [CONTEXT.md](CONTEXT.md) when the script's internal design changes
