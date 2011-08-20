package Alleg::Part::Shield;

=head1 NAME

Alleg::Part::Shield - 

=head1 SYNOPSIS

use Alleg::Part::Shield;

=cut

use strict;
use Carp;

use base qw(Alleg::Part);

use Alleg::Util;
use Alleg::Constants qw(AGC_PartType);
use Alleg::Defaults;

use vars qw(
    $VERSION
    $PACK_FORMAT    @PACK_ORDER $PACK_SIZE
    $AGC_OBJECT_TYPE
    $SPECIAL_FORMAT     @SPECIAL_ORDER
    %DEFAULTS
);

$AGC_OBJECT_TYPE = AGC_PartType;

$VERSION = do { my @r = (q$Revision: 1.7 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$SPECIAL_FORMAT = join('',
    'f',    # float shld_stats_s1; // Recharge rate (was: Points recharged per second)
    'f',    # float shld_stats_s2; // Hitpoints
    'C',    # BYTE shld_AC;        // armor class
    'C',    # BYTE shld_pad;       // CC
    'S',    # unsigned short shld_sound1;//Activate sound
    'S',    # unsigned short shld_sound2;//Desactivate sound
    'C',    # BYTE shld_pad1[1]; // CC CC
    'a*',   # Crap left over (TODO) 
);

@SPECIAL_ORDER = qw(
    recharge_rate   hitpoints
    ac_type         shld_pad
    activate_sound  deactivate_sound
    shld_pad1       TODO
);

# Replace trailing 'a*' format with our specifics
$PACK_FORMAT = $Alleg::Part::PACK_FORMAT;
substr($PACK_FORMAT, -2, 2) = $SPECIAL_FORMAT;

@PACK_ORDER = @Alleg::Part::PACK_ORDER;
splice (@PACK_ORDER, -1, 1, @SPECIAL_ORDER);

$PACK_SIZE = 412;

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
