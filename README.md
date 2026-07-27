# throb-widget README

<!-- Todo rewrite readme -->

a tiny bash utility for a single-character "throb" (pulsing) animation —
drop one character into any line of output to show a long-running program
is still alive.

## Features

- single-character frames, so the throb fits inline into any existing line of output, eg a status message or prompt
- Unicode frame set for modern terminals, with an ASCII fallback for anything else
- ships as one file — source it, or copy its full contents straight into your own script

## Usage

*throb-widget* is meant to be used in either of two ways:

- **source it** — `source throb-widget.sh` from your own script
- **inline it** — copy the full contents of [throb-widget.sh](throb-widget.sh) into your own script

The public API is two functions — start the throb before a foreground
command, stop it after:

```bash
throb_widget_start 0.1   # animates on stderr
curl -s "$url" > /dev/null
throb_widget_stop
```

See [throb-widget-demo.sh](throb-widget-demo.sh) for a runnable demo.


<!-- BUG throb_widget_start "animates on stderr" per line 26 above, but throb-widget.sh writes a leading carriage return before every frame that overwrites the first character of an existing line, breaking the inline-splice claim made at line 11 -->
