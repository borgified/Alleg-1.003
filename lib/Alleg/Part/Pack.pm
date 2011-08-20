package Alleg::Part::Pack;

=head1 NAME

Alleg::Part::Pack - 

=head1 SYNOPSIS

use Alleg::Part::Pack;

=cut

use strict;
use Carp;

use base qw(Alleg::Part);

use Alleg::Util;
use Alleg::Constants qw(AGC_PartType);
use Alleg::Defaults;

use vars qw(
    $VERSION            $PACK_FORMAT    @PACK_ORDER
    $AGC_OBJECT_TYPE
    $SPECIAL_FORMAT     @SPECIAL_ORDER  %DEFAULTS
);

$AGC_OBJECT_TYPE = AGC_PartType;

$VERSION = do { my @r = (q$Revision: 1.8 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$SPECIAL_FORMAT = join('',
    'C',    # BYTE pak_stats_ss1; // Type (0=Ammo,1=fuel)
    'C',    # BYTE pak_pad1; // CC
    'S',    # unsigned short pak_stats_ss2; // Quantity
    'a*',   # Crap left over (TODO) 
);

@SPECIAL_ORDER = qw(
    pack_type
    pak_pad1
    quantity
    TODO
);

# Replace trailing 'a*' format with our specifics
$PACK_FORMAT = $Alleg::Part::PACK_FORMAT;
substr($PACK_FORMAT, -2, 2) = $SPECIAL_FORMAT;

@PACK_ORDER = @Alleg::Part::PACK_ORDER;
splice (@PACK_ORDER, -1, 1, @SPECIAL_ORDER);

sub new {
    my $class = shift;
    return $class->Alleg::CoreObject::new(@_);
}

1;
__END__

=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
