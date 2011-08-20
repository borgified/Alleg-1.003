package Alleg::Faction;

use strict;
use Carp;

use base qw(Alleg::CoreObject);

use Alleg::Util;
use Alleg::Constants qw(AGC_Civilization);
use Alleg::Defaults;

use vars qw($VERSION $PACK_FORMAT @PACK_ORDER $AGC_OBJECT_TYPE %DEFAULTS);

$AGC_OBJECT_TYPE = AGC_Civilization;

$VERSION = do { my @r = (q$Revision: 1.7 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'f2',   # float ukf[2];
    'Z25',  # char name[25];
    'Z13',  # char model[13];
    'Z13',  # char obj[13];
    'a100', # UCHAR techtree[101]; // first = 02
    'a',    # techtree_post - Last char of funky techtree above
    'f25',  # float factors[25];
    'S',    # unsigned short suk;
    'S',    # unsigned short uid;
    'S',    # unsigned short gar_uid; // uid in StationType (or last "base" uid)
    'a2',   # CHAR end[2]; // CD CD
);

@PACK_ORDER = qw(
    ukf1    ukf2
    name    model   obj
    techtree    techtree_post
    factor_01   factor_02   factor_03   factor_04   factor_05
    factor_06   factor_07   factor_08   factor_09   factor_10
    factor_11   factor_12   factor_13   factor_14   factor_15
    factor_16   factor_17   factor_18   factor_19   factor_20
    factor_21   factor_22   factor_23   factor_24   factor_25
    suk
    uid
    gar_uid
    end
);

1;
__END__
