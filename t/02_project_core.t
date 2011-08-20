#
# $Id: 02_project_core.t,v 1.4 2002/12/09 22:43:15 Administrator Exp $
# $Name: RELEASE_1_3 $

use strict;
use vars qw($test $ok $total);

sub OK { print "ok " . $test++ . "\n" }
sub NOT_OK { print "not ok " . $test++ . "\n"};

BEGIN { $test = 1; $ok=0; $| = 1 }
END { NOT_OK unless $ok }

use Alleg::Core;
use Config;
use Cwd;

$ok++; OK;

for my $igc (glob("t/cores/*.igc")) {
    open IGC, $igc or die "open($igc): $!";

    my $zone_core;
    {
        local $/;
        $zone_core = <IGC>;
    }
    seek IGC, 0, 0 or die $!;

    my $core = Alleg::Core->new_from_fh(\*IGC);
    
    close IGC or die "close($igc): $!";

    unlink glob("t/test/PICE_TEST/*");

    mkdir("t/test"); # Ignore return

    $core->export_pice("t/test/PICE_TEST");

    my $new_core;

    my $cwd = cwd();

    chdir("t/test/PICE_TEST") || die "Can not change to pICE test directory 't/test/PICE_TEST': $!";
    
    if (system("$Config{perlpath} -I$cwd/blib/lib my_core.pl") == 0) {
        open IGC, "my_core.igc"
            or die "open(my_core.igc): $!";
        {
            local $/;
            $new_core = <IGC>;
        }
        close IGC;
    }
    else {
        warn "system(): $!";
    }

    if ($zone_core eq $new_core) {
        OK;
    }
    else {
        NOT_OK;
    }
    chdir($cwd) or die "chdir($cwd): $!";
}

## Set $total to the total number of t/cores/*.igc files + 1
BEGIN { $total = 8 ; print "1..$total\n"; }
