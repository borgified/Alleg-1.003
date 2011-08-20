package Alleg::Missile;

=head1 NAME

Alleg::Missile - 

=head1 SYNOPSIS

use Alleg::Missile;

=cut

use strict;
use Carp;

use base qw(Alleg::CoreObject);

use Alleg::Util;
use Alleg::Constants qw(AGC_MissileType);
use Alleg::Defaults;

use vars qw($VERSION $PACK_FORMAT @PACK_ORDER $AGC_OBJECT_TYPE %DEFAULTS);

$AGC_OBJECT_TYPE = AGC_MissileType;

$VERSION = do { my @r = (q$Revision: 1.6 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'a16',  # UCHAR header[16]; // ALL ZERO - Checked
    'f',    # float stats_s1;   // scale
    'f',    # float stats_s2;   // rate rotation
    'Z13',  # char ldbmp[13];
    'a13',  # UCHAR pad0[13]; // ALL ZERO - Checked
    'a2',   # UCHAR pad1[2];  // CC - Checked
    'f',    # float stats_s3;   // reload time
    'f',    # float stats_s4;   // life span
    'f',    # float stats_s5;   // sig
    'l',    # AGCMoney cost;
    'l',    # int pad2; // Zero - Checked
    'Z13',  # char model[13];
    'a',    # UCHAR pad3; // C - Checked
    'Z13',  # char type[13]; //part
    'Z25',  # char name[25];
    'Z200', # char description[200];
    'C',    # BYTE group;
    'C',    # BYTE zero;
    'a100', # UCHAR techtree[100];
    'a2',   # char pad4[2];//CC - checked
    'f',    # float stats_sig;  // sig%
    'f',    # float stats_s6;   // mass
    'S',    # unsigned short use_flags;
    'S',    # unsigned short stats_ss1; // cargo payload
    'f',    # float stats_s16;          // hitpoints
    'C',    # BYTE AC; // 0B
    'a',    # UCHAR pad5[1]; // 0B CD - Checked
    'S',    # unsigned short uid;
    'S',    # unsigned short special_effect; // 1 for nerve, 2 for reso , 0 otherwise
    'Z13',  # char icon[13]; // SWARM = append '\00s'
    'a',    # char pad6;//CD - Checked
    'f',    # float stats_s7;   // accel
    'f',    # float stats_s8;   // turn radius
    'f',    # float stats_s9;   // launch velocity
    'f',    # float stats_s10;  // lock time
    'f',    # float stats_s11;  // ready time
    'f',    # float stats_s12;  // max lock
    'f',    # float stats_s13;  // CM resistance
    'f',    # float stats_s14;  // salvo ratio
    'f',    # float stats_s15;  // lock radius
    'f',    # float stats_damage;
    'f',    # float stats_unused1; // 0 Checked
    'f',    # float stats_damage_radius;
    'f',    # float stats_unused2; // 0 Checked
    'S',    # unsigned short DM;
    'S',    # unsigned short stats_ss3; //sound launch
    'S',    # unsigned short stats_ss4; //sound flight
    'a2',   # UCHAR end[2]; //CDCD Checked
);

@PACK_ORDER = qw(
    header      scale       rate_rotation   ldbmp
        pad0    pad1
    reload_time life_span   sig         cost
        pad2
    model
        pad3
    type        name        description group   zero
    techtree
        pad4
    sig_mod     mass        use_flags   cargo_payload
    hitpoints   ac
        pad5
    uid         special_effect          icon
        pad6
    accel       turn_radius launch_velocity     lock_time
    ready_time  max_lock    cm_resistance       salvo_ratio
    lock_radius damage      
        stats_unused1
    damage_radius
        stats_unused2
    dm  sound_launch    sound_flight
        end
);

1;
__END__

=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
