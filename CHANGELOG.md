# throb-widget CHANGELOG

[^format]

## [Unreleased]

### Added
- `throb_widget_start` / `throb_widget_stop`, the two public functions; a background async pair for animating while the caller is blocked on a foreground command
- `throb-widget-demo.sh`, a 10-second demo of the throb widget
<!-- FIXME the demo has run for 5 seconds since commit 870c5ea, this entry was not updated -->
<!-- FIXME this section never mentions the locale-driven frame selection (Unicode set, ASCII fallback, and the detection that switches between them), even though it is shipped, headline behavior -->

### Changed
- nothing yet

### Deprecated
- nothing yet

### Removed
- nothing yet

### Fixed
- nothing yet

### Security
- nothing yet

[Unreleased]: https://github.com/kami-lel/throb-widget/compare/54fce07...HEAD
<!-- FIXME this link points at github.com/kami-lel/throb-widget, but the project was renamed to bash-throb-widget in commit c2521ce and the remote now is git@github.com:kami-lel/bash-throb-widget.git -->

<!-- FIXME CONTEXT.md:40-41 claims the frame set is "chosen at runtime or by the caller", but no caller-selectable mechanism exists: throb_widget_get_frame consults only throb_widget_is_utf8_locale, and the only public parameter is the interval -->
<!-- TODO no continuous integration configuration exists, so none of the AGENTS.md constraints (private-function prefix at line 18, frame-count parity at line 20, single-character-per-frame rule at line 19) has any executable check; every constraint is enforced by convention alone -->
<!-- TODO throb-widget.sh:49-57 forks a loop with no trap on EXIT/INT/TERM, so a caller that exits without calling throb_widget_stop leaks the loop as an orphaned process; this is undocumented in README.md and CONTEXT.md -->













<!-- footnotes -->

[^format]: the format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

