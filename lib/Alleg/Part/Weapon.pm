package Alleg::Part::Weapon;

=head1 NAME

Alleg::Part::Weapon - 

=head1 SYNOPSIS

use Alleg::Part::Weapon;

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

$VERSION = do { my @r = (q$Revision: 1.6 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$SPECIAL_FORMAT = join('',
    'f',    # float wep_stats_s1;           // Time ready
    'f',    # float wep_stats_s2;           // Shot interval
    'f',    # float wep_stats_s3;           // Energy consumption
    'f',    # float wep_stats_s4;           // Particle spread
    'S',    # unsigned short wep_stats_ss1; // ammo consumption
    'S',    # unsigned short wep_projectile_uid;
    'S',    # unsigned short wep_stats_ss2; // activation sound
    'S',    # unsigned short wep_stats_ss3; // shot sound
    'S',    # unsigned short wep_stats_ss4; // burst sound
    'a2',   # BYTE wep_pad1[2]; // CC CC
    'a*',   # Crap left over (TODO) 
);

@SPECIAL_ORDER = qw(
    time_ready          shot_interval
    energy_consumption  particle_spread
    ammo_consumption    wep_projectile_uid
    activation_sound    shot_sound
    burst_sound
    wep_pad1
    TODO
);

# Replace trailing 'a*' format with our specifics
$PACK_FORMAT = $Alleg::Part::PACK_FORMAT;
substr($PACK_FORMAT, -2, 2) = $SPECIAL_FORMAT;

@PACK_ORDER = @Alleg::Part::PACK_ORDER;
splice (@PACK_ORDER, -1, 1, @SPECIAL_ORDER);

$PACK_SIZE = 424;

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
