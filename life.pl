#!/usr/bin/perl
#
# Conway's game of Life
# Note: This script is optimized for performance and tightness of code rather than readability
#
# R. Sweet	2016

use Curses;
use Getopt::Long;

# command line options, parsed before initscr so errors are still visible
my $restart_after = 0;	# generations between automatic restarts, 0 = never
GetOptions('restart|r=i' => \$restart_after) or usage();
usage() if $restart_after < 0 || @ARGV;

sub usage {
	print STDERR "Usage: $0 [-r | --restart <generations>]\n";
	print STDERR "  -r, --restart <generations>  restart with a new random pattern\n";
	print STDERR "                               every <generations> generations (0 = never)\n";
	exit 1;
}

my $gen = 0;	# generations since the last (re)start
my $density = 30;	# percent of cells initialized to alive

initscr;		# curses calls to set up screen
nodelay(1);		# tells curses not to wait for a keystroke on getch()
noecho;			# don't echo keystrokes to screen

# initialize the world 
init:	# if user hits 'r' we jump back here and start over 
for $y (0 .. $LINES-1) {
	for $x (0 .. $COLS-1) {
		$$today[$x][$y] = int(rand(100)) < $density ? 1 : 0;
	}
}

while (1) {
	for $y (0 .. $LINES-1) {
		for $x (0 .. $COLS-1) {
			# display current generation, but only if a cell has changed state
			addch($y, $x, $$today[$x][$y] ? 'O' : ' ') if $$tomorrow[$x][$y] != $$today[$x][$y];

			# calculate next generation
			# count neighbors
			$u = $y ? $y-1 : $LINES;
			$l = $x ? $x-1 : $COLS;
			$r = $x+1 == $COLS ? 0 : $x+1;
			$d = $y+1 == $LINES ? 0 : $y+1;

			$n = $$today[$l][$u] + $$today[$x][$u] + $$today[$r][$u] +
			     $$today[$l][$y] +                   $$today[$r][$y] +
			     $$today[$l][$d] + $$today[$x][$d] + $$today[$r][$d];

			$$tomorrow[$x][$y] = 0;				# default to dead since that's the most common state
			$$tomorrow[$x][$y] = 1 if $n == 3;	# a cell will stay alive or be born if 3 neighbors
			$$tomorrow[$x][$y] = $$today[$x][$y] if $n == 2;	# state remains the same if 2 neighbors
		}
	}
	refresh;	# tell curses to refresh (redraw) the screen

	# swap today and tomorrow
	($today, $tomorrow) = ($tomorrow, $today);

	# automatic restart, the same jump the 'r' key makes
	if ($restart_after && ++$gen >= $restart_after) {
		$gen = 0;
		goto init;
	}

	$ch = getch();
	last if $ch eq 'q';
	goto init if $ch eq 'r';
}

# make damn sure endwin gets called even if we crash or SIGTERM by putting it in the END block
END { endwin; }
