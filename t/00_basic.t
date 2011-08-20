use strict;
use vars qw($test $ok $total);

sub OK { print "ok " . $test++ . "\n" }
sub NOT_OK { print "not ok " . $test++ . "\n"};

BEGIN { $test = 1; $ok=0; $| = 1 }
END { NOT_OK unless $ok }

use Alleg;

$ok++; OK;

if ('am I ok') {
    OK;
}
else {
    NOT_OK;
}

## or better yet
'am I ok'
    ? OK
    : NOT_OK;

## Set $total to the total number of tests this file runs
BEGIN { $total = 3 ; print "1..$total\n"; }
