#!/usr/bin/perl
#
# Conway's game of Life

$clear="\x1b\x5b\x48\x1b\x5b\x4a";	# terminal escape sequence to clear screen
$maxX = 80;
$maxY = 60;

# initialize the world
for ($y=0;$y<$maxY;$y++) {
	for ($x=0;$x<$maxX;$x++) {
		$$e1[$x][$y] = int(rand(5)) ? 0 : 1;
	}
}

while (1) {
	print $clear;
	for ($y=0;$y<$maxY;$y++) {
		for ($x=0;$x<$maxX;$x++) {
			# display current generation
			print $$e1[$x][$y] ? 'O' : ' ';

			# calculate next generation
			# count neighbors
			$u = $y ? $y-1 : $maxY;
			$l = $x ? $x-1 : $maxX;
			$r = $x+1 == $maxX ? 0 : $x+1;
			$d = $y+1 == $maxY ? 0 : $y+1;

			$n = $$e1[$l][$u] + $$e1[$x][$u] + $$e1[$r][$u] +
			     $$e1[$l][$y] +                $$e1[$r][$y] +
			     $$e1[$l][$d] + $$e1[$x][$d] + $$e1[$r][$d];

			$$e2[$x][$y] = 0;				# default to dead since that's the most common state
			$$e2[$x][$y] = 1 if $n == 3;	# a cell will stay alive or be born if 3 neighbors
			$$e2[$x][$y] = $$e1[$x][$y] if $n == 2;	# state remains the same if 2 neighbors
		}
		print "\n";
	}

	# swap today and tomorrow
	$tmp = $e1; $e1 = $e2; $e2 = $tmp;
}
