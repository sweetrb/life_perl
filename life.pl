#!/usr/bin/perl
#
# Conway's game of Life
# Note: This script is optimized for performance and tightness of code rather than readability
#
# R. Sweet	2016

use Curses;
use Getopt::Long;
use Time::HiRes qw(time);

# command line options, parsed before initscr so errors are still visible
my $restart_after = 0;		# generations between automatic restarts, 0 = never
my $show_generations = 0;	# put the generation count in the pane title
my $show_time = 0;		# put the time per generation in the pane title
GetOptions('restart|r=i' => \$restart_after,
           'generations|g' => \$show_generations,
           'time|t' => \$show_time) or usage();
usage() if $restart_after < 0 || @ARGV;

sub usage {
	print STDERR "Usage: $0 [-r | --restart <generations>] [-g | --generations] [-t | --time]\n";
	print STDERR "  -r, --restart <generations>  restart with a new random pattern\n";
	print STDERR "                               every <generations> generations (0 = never)\n";
	print STDERR "  -g, --generations            show the generation count in the pane title\n";
	print STDERR "  -t, --time                   show the time per generation in the pane title\n";
	exit 1;
}

# set the terminal's (or iTerm pane's) title.  OSC 1 leaves the cursor and
# attributes alone, so it is safe to write around curses.
sub set_title {
	my ($generations, $us_per_gen) = @_;
	my $title = 'Perl';
	$title .= " | gen $generations" if $show_generations;
	$title .= sprintf(' | %.1f us/gen', $us_per_gen) if $show_time && $us_per_gen > 0;

	local $| = 1;
	print "\033]1;$title\007";
}

# how often the pane title is refreshed, in seconds.  Rewriting it every
# generation would cost more than the game does.
my $title_interval = 0.1;
my $titled = $show_generations || $show_time;
my $generations = 0;	# generations since the program started
my $sampled = time;
my $sampled_at = 0;
my $us_per_gen = 0;

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
	$generations++;
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

	# refresh the pane title, at most every $title_interval
	if ($titled) {
		my $now = time;
		my $elapsed = $now - $sampled;
		if ($elapsed >= $title_interval) {
			$us_per_gen = $elapsed * 1_000_000 / ($generations - $sampled_at)
				if $generations > $sampled_at;
			set_title($generations, $us_per_gen);
			$sampled = $now;
			$sampled_at = $generations;
		}
	}

	$ch = getch();
	last if $ch eq 'q';
	goto init if $ch eq 'r';
}

# make damn sure endwin gets called even if we crash or SIGTERM by putting it in the END block
END { endwin; }
