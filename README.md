# bash-throb-widget README

a tiny bash utility for a single-character "throb" (pulsing) animation —
drop one character into any line of output to show a long-running program
is still alive.

## Features

- single-character frames, so the throb fits inline into any existing line of output, eg a status message or prompt
- Unicode frame set for modern terminals, with an ASCII fallback for anything else
- ships as one file — source it, or copy its full contents straight into your own script

## Status

this project is in early scaffolding. [bash-throb-widget.sh](bash-throb-widget.sh)
is currently an empty placeholder — the animation logic is planned but not
yet implemented. See [CONTEXT.md](CONTEXT.md) for the planned design.

## Usage

*bash-throb-widget* is meant to be used in either of two ways:

- **source it** — `source bash-throb-widget.sh` from your own script
- **inline it** — copy the full contents of [bash-throb-widget.sh](bash-throb-widget.sh) into your own script

Once implemented, the frame sets will look like this:

```bash
FRAMES_PULSE=('░' '▒' '▓' '█' '▓' '▒')
FRAMES_PULSE_ASCII=('.' 'o' 'O' '@' 'O' 'o')
```

## Project Structure

| file | purpose |
| --- | --- |
| [bash-throb-widget.sh](bash-throb-widget.sh) | the entire utility |