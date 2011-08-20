package Alleg::Projectile;

=head1 NAME

Alleg::Projectile - Alleg::Projectile

=head1 SYNOPSIS

use Alleg::Projectile;

=cut

use strict;
use Carp;

use base qw(Alleg::CoreObject);
use Alleg::Util;
use Alleg::Constants qw(AGC_ProjectileType);
use Alleg::Defaults;

use vars qw($VERSION $PACK_FORMAT @PACK_ORDER $AGC_OBJECT_TYPE);

$AGC_OBJECT_TYPE = AGC_ProjectileType;

$VERSION = do { my @r = (q$Revision: 1.4 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'f',    # float pcRED; // all zero = percent RGBA
    'f',    # float pcGreen;
    'f',    # float pcBlue;
    'f',    # float pcAlpha;
    'f',    # float stats_s1;   // particle size (radius)
    'f',    # float stats_s2;   // rate rotation (?)
    'Z13',  # file_model[13];   // ALL '0' = file model
    'Z13',  # file_texture[13]; // = file texture
    'a2',   # char pad2[2];     // CC CC
    'f',    # float stats_s3;   // regular damange per shot
    'f',    # float stats_s4;   // area damange per shot
    'f',    # float stats_s5;   // area damage radius
    'f',    # float stats_s6;   // speed
    'f',    # float stats_s7;   // life span
    'S',    # unsigned short uid;
    'C',    # BYTE DM;
    'C',    # BYTE stats_ss1;   // absolute speed = 1
    'C',    # BYTE stats_ss2;   // directional = 1
    'a3',   # UCHAR pad3[3];    // CC CC CC
    'f',    # float stats_s8;   // Width OverHeigth
    'S',    # unsigned short ambient_sound;
    'a2',   # UCHAR pad4[2];    // CC CC
);

@PACK_ORDER = qw(
    pc_red          pc_green        pc_blue     pc_alpha
    particle_size   rate_rotation   file_model  file_texture
        pad2
    reg_dmg_per_shot    area_dmg_per_shot
    area_dmg_radius     speed       lifespan
    uid             dm
    absolute_speed  directional
        pad3
    width_over_height   ambient_sound
        pad4
);

=cut

1;
__END__


=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
