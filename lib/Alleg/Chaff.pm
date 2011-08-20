package Alleg::Chaff;

=head1 NAME

Alleg::Chaff - 

=head1 SYNOPSIS

use Alleg::Chaff;

=cut

use strict;
use Carp;

use base qw(Alleg::CoreObject);

use Alleg::Util;
use Alleg::Constants qw(AGC_ChaffType);
use Alleg::Defaults;

use vars qw($VERSION $PACK_FORMAT @PACK_ORDER $AGC_OBJECT_TYPE %DEFAULTS);

$AGC_OBJECT_TYPE = AGC_ChaffType;

$VERSION = do { my @r = (q$Revision: 1.6 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'f',    # float pcRED; // all zero = percent RGBA
    'f',    # float pcGreen;
    'f',    # float pcBlue;
    'f',    # float pcAlpha;
    'f',    # float stats_s1; // radius
    'f',    # float stats_s2; // rate rotation
    'a13',  # UCHAR pad0[13]; // all 0
    'Z13',  # char icon[13];
    'a2',   # char pad1[2]; //CC
    'f',    # float stats_s3; // load time
    'f',    # float stats_s4; // life span
    'f',    # float stats_s5; // sig
    'f',    # float stats_s6; // cost
    'f',    # float stats_s7; // build time (seconds)
    'Z13',  # char model[13];
    'a',    # char pad3; // C
    'Z13',  # char type[13]; //part
    'Z25',  # char name[25];
    'Z200', # char description[200];
    'C',    # BYTE group;
    'C',    # BYTE zero;
    'a100', # UCHAR techtree[100];
    'a2',   # char pad4[2]; // CC
    'f',    # float stats_s8; // sig mod (%)
    'f',    # float stats_s9; // mass
    'S',    # unsigned short use_mask;
    'S',    # unsigned short stats_ss1;//1 - todo
    'f',    # float stats_s10; // hitpoint
    'C',    # BYTE AC;
    'a',    # UCHAR pad5[1]; //  0B CD 
    'S',    # unsigned short uid;
    'S',    # unsigned short stats_ss2;//0
    'Z13',  # char ukbmp[13];
    'a',    # UCHAR pad6; //CC
    'f',    # float stats_s11; // strength
);
@PACK_ORDER = qw(
    pc_red      pc_green        pc_blue     pc_alpha
    radius      rate_rotation
        pad0
    icon
        pad1
    load_time   life_span   sig         cost
    build_type  model
        pad3
    type        name        description
    group       zero        techtree
        pad4
    sig_mod     mass        use_mask    stats_ss1
    hitpoints   ac
        pad5
    uid         stats_ss2   ukbmp
        pad6
    strength
);

1;
__END__


=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
