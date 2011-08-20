#
# $Id: 01_read_write_igc.t,v 1.2 2002/10/10 01:16:37 Administrator Exp $
# $Name: RELEASE_1_3 $

use strict;
use vars qw($test $ok $total);

sub OK { print "ok " . $test++ . "\n" }
sub NOT_OK { print "not ok " . $test++ . "\n"};

BEGIN { $test = 1; $ok=0; $| = 1 }
END { NOT_OK unless $ok }

use Alleg::Core;

$ok++; OK;

for my $igc (glob("t/cores/*.igc")) {
    eval {
        open IGC, $igc or die "open($igc): $!";
        
        my $zone_core;
        {
            local $/;
            $zone_core = <IGC>;
        }
        seek IGC, 0, 0 or die $!;
        
        my $core = Alleg::Core->new_from_fh(\*IGC);
        close IGC or die "close($igc): $!";
        my $new_core = $core->pack();

        if ($ENV{DEBUG}) {
            eval "use Data::Dumper;"; die if $@;
            open TEST_CRAP, ">t/test/debug_$igc.pl" or die "open(>t/test/debug_$igc.pl): $!";
            print TEST_CRAP Dumper($core);
            close TEST_CRAP;
        }
        
        if ($zone_core eq $new_core) {
            OK;
        }
        else {
            NOT_OK;
            if ($ENV{DEBUG}) {
                eval "use Data::Dumper;"; die if $@;
                open DEBUG_IGC, ">t/test/debug_$igc" or die "open(>t/test/debug_$igc): $!";
                print DEBUG_IGC $new_core;
                close DEBUG_IGC or die "close(>t/test/debug_$igc): $!";
            }
        }
    };
    NOT_OK if $@;
}

## Set $total to the total number of t/cores/*.igc files + 1
BEGIN { $total = 8 ; print "1..$total\n"; }
