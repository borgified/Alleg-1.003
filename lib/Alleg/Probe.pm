package Alleg::Probe;

=head1 NAME

Alleg::Probe - 

=head1 SYNOPSIS

use Alleg::Probe;

=cut

use strict;
use Carp;

use base qw(Alleg::CoreObject);

use Alleg::Util;
use Alleg::Constants qw(AGC_ProbeType);
use Alleg::Defaults;

use vars qw($VERSION $PACK_FORMAT @PACK_ORDER $AGC_OBJECT_TYPE);

$AGC_OBJECT_TYPE = AGC_ProbeType;

$VERSION = do { my @r = (q$Revision: 1.4 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
            # UCHAR header[16]; // ALL '0' = 4 floats = RGBA values (as in SIGCCoreMine)
    'f',    # float pcRED;      // all zero = percent RGBA
    'f',    # float pcGreen;
    'f',    # float pcBlue;
    'f',    # float pcAlpha;
    'f',    # float stats_s1;   // scale
    'f',    # float stats_s2;   // rate rotation
    'Z13',  # char model[13];
    'a13',  # char model1[13];
    'a2',   # char pad1[2]; // CC CC
    'f',    # float stats_s3;   // arming time
    'f',    # float stats_s4;   // lifespan
    'f',    # float stats_s5;   // sig
    'l',    # AGCMoney cost;
    'a4',   # UCHAR TODO1[4];   // all '0'
    'Z13',  # char ukbmp[13];   // inactive/loadout model
    'a',    # char pad2;        // CC
    'Z13',  # char type[13];    // part
    'Z25',  # char name[25];
    'Z200', # char description[200];
    'C',    # BYTE group;
    'C',    # BYTE zero;
    'a100', # UCHAR techtree[100];
    'a2',   # char pad3[2];     // CD CD
    'a4',   # UCHAR TODO2[4];   // all '0', might be a float
    'f',    # float stats_s6;   // mass
    'S',    # unsigned short stats_ss1; // usemask
    'S',    # unsigned short stats_ss2; // cargo playload
    'f',    # float stats_s7;   // hitpoints
    'a2',   # char pad4[2];     // 0B CD
            # Zen - BYTE AC like the others?!
    'S',    # unsigned short uid;
    'S',    # unsigned short stats_ss3;
            # // features (bits mask, as in AbilityBitMask in igc.h)
    'Z13',  # char icon[13];
    'a',    # char pad5;        // CD
    'f',    # float stats_s8;   // scan range
    'f',    # float stats_s9;   // shot interval
    'f',    # float stats_s10;  // accuracy
    'f',    # float stats_s11;  // leading
    's',    # short stats_ss4;  // ammo capacity
    's',    # short stats_projectile;
    's',    # short stats_sound; // 720 mainly (soundprobe)
    'a2',   # UCHAR pad6[2];    // CD CD
    'f',    # float stats_activation_delay; // -1 or # secs for teleport activation
);

@PACK_ORDER = qw(
    pc_red      pc_green        pc_blue     pc_alpha
    scale       rate_rotation   model       model1
        pad1
    arming_time lifespan        sig         cost
        TODO1
    loadout_model
        pad2
    type        name            description group
    zero        techtree
        pad3    TODO2
    mass        usemask         cargo_payload
    hitpoints 
        pad4
    uid         features        icon
        pad5
    scan_range      shot_interval   accuracy    leading
    ammo_capacity   projectile      sound
        pad6
    activation_delay
);

1;
__END__


=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
