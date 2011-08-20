package Alleg::Research;

use strict;
use Carp;

use base qw(Alleg::CoreObject);

use Alleg::Util;
use Alleg::Constants qw(AGC_Development);
use Alleg::Defaults;

use vars qw($VERSION $PACK_FORMAT @PACK_ORDER $AGC_OBJECT_TYPE);

$AGC_OBJECT_TYPE = AGC_Development;

$VERSION = do { my @r = (q$Revision: 1.2 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'L',    # UINT cost;
    'L',    # UINT research_time;
    'Z13',  # char model[13];
    'C',    # UCHAR uk1; // cc
    'Z13',  # char icon[13]; // always 'icontech'
    'Z25',  # char name[25];
    'Z200', # char description[200];
    'C',    # UCHAR pad1;//00
    'C',    # UCHAR root_tree;// tree root (0=construction,1=garrison,2=sup,3=tac,4=exp,5=sy)
    'a100', # UCHAR techtree[100];
    'a2',   # UCHAR pad2[2]; // cd cd
    'f25',  # float factors[25];//
    'S',    # unsigned short uid;
    'S',    # unsigned short cat;
);

@PACK_ORDER = qw(
    cost    research_time
    model
    uk1
    icon    name    description
    pad1
    root_tree
    techtree
    pad2
    factor_01   factor_02   factor_03   factor_04   factor_05
    factor_06   factor_07   factor_08   factor_09   factor_10
    factor_11   factor_12   factor_13   factor_14   factor_15
    factor_16   factor_17   factor_18   factor_19   factor_20
    factor_21   factor_22   factor_23   factor_24   factor_25
    uid         cat
);

1;
__END__
