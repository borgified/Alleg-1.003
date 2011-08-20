package Alleg;

use strict;
use vars qw($VERSION @ISA @EXPORT);
$VERSION    = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};
@ISA        = qw(Exporter);
@EXPORT     = qw(export);

require Exporter;

use Alleg::Core;

sub export {
    my $igc = shift @ARGV
        or die qq(Missing IGC file name.  Usage: perl -MAlleg -e export some_core.igc C:\target_directory\n);
    my $dir = shift @ARGV
        or die qq(Missing target directory name.  Usage: perl -MAlleg -e export some_core.igc C:\target_directory\n);

    open IGC, $igc
        or die "open($igc): $!";
    my $core = Alleg::Core->new_from_fh(\*IGC);
    $core->export_pice($dir);
    close IGC;
}

1;
__END__

=head1 NAME

Alleg - pICE (Perl ICE)

=head1 SYNOPSIS

    perl -MAlleg -e export zone_core.igc C:\target_directory

=head1 DESCRIPTION

pICE is intended as a comprehensive API for constructing

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

Alleg::Core

=cut
