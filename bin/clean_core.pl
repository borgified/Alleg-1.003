#!/usr/bin/perl -w

use strict;
use Alleg;

my $USAGE = "Usage: $0 my_core.igc > clean_core.igc";

use Alleg::Core;

my $igc = shift
    or die $USAGE;

open IGC, $igc
    or die "open($igc): $!";

my $core = Alleg::Core->new_from_fh(\*IGC);
close IGC
    or die "close($igc): $!";

print $core->pack()
    or die;

exit 0;
