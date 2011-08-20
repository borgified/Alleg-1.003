package Alleg::Part::Booster;

=head1 NAME

Alleg::Part::Booster - 

=head1 SYNOPSIS

use Alleg::Part::Booster;

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

$VERSION = do { my @r = (q$Revision: 1.6 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$SPECIAL_FORMAT = join('',
    'f',    # float aftb_stats_s1; // Rate of consumption
    'f',    # float aftb_stats_s2; // Thrust amount
    'f',    # float aftb_stats_s3; // % acceleration
    'f',    # float aftb_stats_s4; // Release duration
    'S',    # unsigned short aftb_stats_ss1; // activate sound
    'S',    # unsigned short aftb_stats_ss2; // desactivate sound
    'a*',   # Crap left over (TODO) 
);

@SPECIAL_ORDER = qw(
    consumption     thrust
    acceleration    release_duration
    activate_sound  deactivate_sound
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
