package Alleg::Drone;

use strict;
use Carp;

use base qw(Alleg::CoreObject);

use Alleg::Util;
use Alleg::Constants qw(AGC_DroneType);
use Alleg::Defaults;

use vars qw($VERSION $PACK_FORMAT @PACK_ORDER $AGC_OBJECT_TYPE %DEFAULTS);

$AGC_OBJECT_TYPE = AGC_DroneType;

$VERSION = do { my @r = (q$Revision: 1.5 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'l',    # AGCMoney cost; // 1 for con, 4000 for miner
    'l',    # AGCMoney research_time; // 1 for con, 90 for miner
    'Z13',  # char model[13];
    'a',    # char pad1;        // CC
    'a13',  # char uks1[13];    // null string
    'Z25',  # char name[25];
    'Z200', # char description[200];
    'C',    # BYTE group;
    'C',    # BYTE zero;
    'a100', # UCHAR techtree[100];
    'a2',   # char pad2[2];     // CC
    'f',    # float f1;         // ?, def = 0.5
    'f',    # float f2;         // ?, def = 0.5
    'f',    # float f3;         // ?, def = 0.5
    'C',    # BYTE ss1;         // AI script: miner=0,wingman=2,layer=5,con=6,carrier=9
    'a',    # char pad3;        // CC
    'S',    # unsigned short ship_uid;
    'S',    # unsigned short uid;
    's',    # short part_uid;   // -1 if none, otherwise uid of mines/probes
);

@PACK_ORDER = qw(
    cost    research_time
    model
        pad1
    null_string
    name    description
    group   zero
    techtree
        pad2
    f1  f2  f3
    ai_script
        pad3
    ship_uid    uid
    part_uid
);

1;
__END__
