# Conway's Game of Life in Perl

A terminal-based implementation of Conway's Game of Life using Perl and Curses.

This version uses the Curses.pm library and was developed on a Raspberry Pi 2 running Raspbian.
It has also been verified on OS X El Capitan 10.11.4 through macOS Tahoe.

## Author

Rob Sweet

## Running

```bash
perl life.pl
```

## Controls

- `q` - Quit
- `r` - Restart with a new random pattern

## Dependencies

- Perl
- Curses module (`cpan Curses` or via system package manager)
