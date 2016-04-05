#!/usr/bin/perl
#
# Conway's game of Life
# Note:  this script is optimized for tightness of code rather than readability

use Curses;

initscr;		# curses calls to set up screen
nodelay(1);		# tells curses not to wait for a keystroke on getch()
noecho;			# don't echo keystrokes to screen

# initialize the world 
init:	# if user hits 'r' we jump back here and start over 
for ($y=0;$y<$LINES;$y++) {
	for ($x=0;$x<$COLS;$x++) {
		$$e1[$x][$y] = int(rand(5)) ? 0 : 1;
	}
}

while (! $done) {
	for ($y=0;$y<$LINES;$y++) {
		for ($x=0;$x<$COLS;$x++) {
			# display current generation
			addstr($y, $x, $$e1[$x][$y] ? 'O' : ' ');

			# calculate next generation
			# count neighbors
			$u = $y ? $y-1 : $LINES;
			$l = $x ? $x-1 : $COLS;
			$r = $x+1 == $COLS ? 0 : $x+1;
			$d = $y+1 == $LINES ? 0 : $y+1;

			$n = $$e1[$l][$u] + $$e1[$x][$u] + $$e1[$r][$u] +
			     $$e1[$l][$y] +                $$e1[$r][$y] +
			     $$e1[$l][$d] + $$e1[$x][$d] + $$e1[$r][$d];

			$$e2[$x][$y] = 0;				# default to dead since that's the most common state
			$$e2[$x][$y] = 1 if $n == 3;	# a cell will stay alive or be born if 3 neighbors
			$$e2[$x][$y] = $$e1[$x][$y] if $n == 2;	# state remains the same if 2 neighbors
		}
	}
	refresh;

	# swap today and tomorrow
	$tmp = $e1; $e1 = $e2; $e2 = $tmp;

	$ch = getch();
	$done = 1 if $ch eq 'q';
	goto init if $ch eq 'r';
}

# make damn sure endwin gets called by putting it in the END block, this way even if we crash or 
# catch an interrupt it will be called.
END { endwin; }
