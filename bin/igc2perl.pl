#!/usr/bin/perl -w
# $Id: igc2perl.pl,v 1.2 2004/01/16 01:31:49 Administrator Exp $
# $Name: RELEASE_1_3 $

my $USAGE = "Usage: $0 my_core.igc project_dir";

use Alleg::Core;
use File::Basename;

my $igc = shift
    or die $USAGE;
my $dir = shift || basename($igc, '.igc','.IGC');

open IGC, $igc
    or die "open($igc): $!";

my $core = Alleg::Core->new_from_fh(\*IGC);
close IGC
    or die "close($igc): $!";

$core->export_pice($dir);
