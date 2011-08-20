package Alleg::Station;

use strict;
use Carp;

use base qw(Alleg::CoreObject);

use Alleg::Util;
use Alleg::Constants qw(AGC_StationType);
use Alleg::Defaults;

use vars qw($VERSION $PACK_FORMAT @PACK_ORDER $AGC_OBJECT_TYPE);

$AGC_OBJECT_TYPE = AGC_StationType;

$VERSION = do { my @r = (q$Revision: 1.4 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'l',    # AGCMoney cost;
    'l',    # AGCMoney research_time;
    'Z13',  # char model[13];
    'a',    # char pad1;//CC or 00
    'Z13',  # char icon[13];
    'Z25',  # char name[25];
    'Z200', # char description[200];
    'C',    # BYTE group;
    'C',    # BYTE zero;
    'a100', # UCHAR techtree[100];
    'a2',   # char pad2[2]; // CD CD
    'f',    # float stats_s1; // sig multiplier
    'f',    # float stats_s2; // hull
    'f',    # float stats_s3; // shield
    'f',    # float stats_s4; // hull repair rate
    'f',    # float stats_s5; // shield repair rate
    'f',    # float stats_s6; // scan range
    'l',    # AGCMoney stats_income;
    'f',    # float stats_s7; // scale
    'a50',  # UCHAR TechTreeLocal[50];
    'S',    # unsigned short uid;
    'S',    # unsigned short overriding_uid;
    'C',    # UCHAR ACHull;
    'C',    # UCHAR ACShld;
    'S',    # unsigned short AbilityBitMask; // (as in igc.h)
    'S',    # unsigned short buildon; // see IGCSTATIONF_BUILDON_* values
    'C',    # UCHAR type; // see IGCSTATION_TYPE_* value - capture related?
    'C',    # UCHAR pad6; // CD
    'S',    # unsigned short stats_ss0; // drone uid
    'S13',  # unsigned short Sounds[13];
    'a13',  # UCHAR uk3[3*16+1-6-2-28];  // == 13
    'Z25',  # char constructor[25];
);

@PACK_ORDER = qw(
    cost            research_time
    model           pad1
    icon            name            description
    group           zero
    techtree
    pad2
    sig
    hull
    shield
    hull_repair
    sheild_repair
    scan_range
    stats_income
    scale
    techtree_local
    uid
    overriding_uid
    ac_hull         ac_shield
    ability_bitmask
    buildon
    type
    pad6
    stats_ss0
    sound_01        sound_02        sound_03        sound_04    sound_05
    sound_06        sound_07        sound_08        sound_09    sound_10
    sound_11        sound_12        sound_13
    uk3
    constructor
);

1;
__END__
