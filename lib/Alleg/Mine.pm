package Alleg::Mine;

=head1 NAME

Alleg::Mine - 

=head1 SYNOPSIS

use Alleg::Mine;

=cut

use strict;
use Carp;

use base qw(Alleg::CoreObject);

use Alleg::Util;
use Alleg::Constants qw(AGC_MineType);
use Alleg::Defaults;

use vars qw($VERSION $PACK_FORMAT @PACK_ORDER $AGC_OBJECT_TYPE %DEFAULTS);

$AGC_OBJECT_TYPE = AGC_MineType;

$VERSION = do { my @r = (q$Revision: 1.7 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'f',    # float pcRED;              // all zero = percent RGBA
    'f',    # float pcGreen;
    'f',    # float pcBlue;
    'f',    # float pcAlpha;
    'a4',   # UCHAR pad0[4];            // all 'CC' (could be float 'scale')
    'f',    # float stats_s1;           // rate rotation
    'a13',  # UCHAR pad1[13];           // all '00'
    'Z13',  # char icon[13];            // fxmine
    'a2',   # UCHAR pad2[2];            // all 'CC'
    'f',    # float stats_s2;           // load time
    'f',    # float stats_duration;
    'f',    # float stats_s3;           // sig
    'l',    # AGCMoney cost;
    'a4',   # UCHAR pad3[4];            // all '00'
    'Z13',  # char model[13];           // inactive & loadout bmp (prefix with 'l')
    'a',    # char pad4;                // CC
    'Z13',  # char type[13];            // part
    'Z25',  # char name[25];
    'Z200', # char description[200];
    'C',    # BYTE group;
    'C',    # BYTE zero;
    'a100', # UCHAR techtree[100];
    'a2',   # char pad5[2];             // CC
    'f',    # float stats_s4;           // ship sig%
    'f',    # float stats_s5;           // mass
    'S',    # unsigned short stats_ss1; // usemask
    'S',    # unsigned short stats_ss2; // cargo payload
    'f',    # float stats_s6;           // hitpoints
    'C',    # BYTE AC;                  // OB
    'a',    # UCHAR pad6[1];            // CD 
    'S',    # unsigned short uid;
    'S',    # unsigned short pad_zero;  // 0000
    'Z13',  # char ukbmp[13];           // icon bmp
    'a',    # char pad7;                // CC
    'f',    # float stats_radius;
    'f',    # float stats_damage;
    'f',    # float stats_s7;           // ?
    'C',    # BYTE DM;                  // 10
    'a3',   # UCHAR pad8[3];            // CD CD CD
);

@PACK_ORDER = qw(
    pc_red      pc_green    pc_blue pc_alpha
        pad0
    rate_rotation
        pad1
    icon
        pad2
    load_time   duration    sig     cost
        pad3
    model
        pad4
    type        name        description group
    zero        techtree
        pad5
    ship_sig    mass        usemask     cargo_payload
    hitpoints   ac
        pad6
    uid
        pad_zero
    icon_bmp
        pad7
    radius      damage      stats_s7    dm
        pad8
);

1;
__END__


=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
