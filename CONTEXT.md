# throb-widget CONTEXT

Last updated: 2026-07-27

## Project Overview

*throb-widget* is a minimal bash utility for showing a "throb"
(pulsing) animation, a single character that cycles through a shape sequence
to signal a long-running program is still alive.

| | |
| --- | --- |
| **Language** | bash |
| **Entry point** | [throb-widget.sh](throb-widget.sh) |
| **Distribution model** | source the file, or copy its full contents into the caller's script |

## Repository Layout

```
throb-widget/
├── throb-widget.sh        # the entire utility
├── throb-widget-demo.sh   # demo, runs the throb for 10 seconds
├── README.md
├── CHANGELOG.md
├── AGENTS.md
└── CONTEXT.md
```

## Architectural Patterns & Conventions

- **single character per frame** — every animation frame is exactly one
  character, so a caller can splice the current frame into an existing
  line of output (a spinner glued into a status message, a prompt, ~) rather
  than needing a dedicated line
- **dual usage requirement** — the script must work two ways with no code
  changes: (1) `source throb-widget.sh` from another script, and (2)
  the caller copies the file's full text inline into their own script; this
  rules out any pattern that depends on `$0`, `BASH_SOURCE` path lookups, or
  anything else that behaves differently once inlined
- **frame sets** — two parallel arrays hold the pulse shape, chosen at
  runtime or by the caller depending on terminal Unicode support:
  - `FRAMES_PULSE=('░' '▒' '▓' '█' '▓' '▒')` — Unicode block shading, ramps
    light → dark → light
  - `FRAMES_PULSE_ASCII=('.' 'o' 'O' '@' 'O' 'o')` — ASCII fallback with the
    same ramp shape and frame count
- **only two public functions** — `throb_widget_start [interval]` and
  `throb_widget_stop`; every other function is private and must be
  prefixed `throb_widget_` (eg `throb_widget_get_frame`,
  `throb_widget_is_utf8_locale`)
- **background by design** — `throb_widget_start` forks a subshell that
  calls the private `throb_widget_get_frame` in a loop, printing to
  stderr, so the throb animates on its own while the caller is blocked on
  a foreground command; `_throb_widget_pid` tracks the running loop so a
  second `throb_widget_start` while one is active is a no-op

## Known Gaps & Constraints

- no test suite exists yet
