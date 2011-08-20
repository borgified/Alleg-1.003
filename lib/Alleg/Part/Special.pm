package Alleg::Part::Special;

# Super class for missiles, chaff, and mines (Missile, Chaff, Dispenser (mines, yes?)

use strict;
use vars qw($VERSION);

use base qw(Alleg::Part);
use Alleg::CoreObject;
use Carp;
use Alleg::Util;
use Alleg::Constants qw(:part_types AGC_PartType);
use Alleg::Defaults;

# use Alleg::Part::Chaff;
# use Alleg::Part::Missile;
# use Alleg::Part::Dispenser;
# use Alleg::Part::MiscSpecial;

use vars qw(
    $VERSION
    $PACK_FORMAT    @PACK_ORDER
    %DEFAULTS
    $AGC_OBJECT_TYPE
);

$AGC_OBJECT_TYPE = AGC_PartType;

$VERSION = do { my @r = (q$Revision: 1.4 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join ('',
    'S',    # unsigned short suk2;
    'S',    # unsigned short uid; //
    'S',    # unsigned short overriding_uid;    // uid of part that overrides this one (0xFFFF if none)
    'S',    # unsigned short type;              // 1 = weapon, 2 = shield, 5 = cloak, 7 = after, 6 = default
    'S',    # unsigned short usemask;           // = uid a corresponding object for SPECS PARTS
    'Z13',  # char slot[13];
    'a',    # char pad3[1];                     // CC -  END FOR MISSILE/CHAFF/MINES (SPECS PARTS)
);

@PACK_ORDER = qw(
    suk2
    uid     overriding_uid
    type    usemask
    slot    pad3
);

sub get_defaults {
    return %DEFAULTS;
}

sub new {
    my $class = shift;
    my %args = @_;
    unless (exists $args{Struct}) {
        confess "Required field Struct field missing.";
    }
    unless (length($args{Struct}) == 0x18) {
        confess "Struct '$args{Struct}' is incorrect length to be a special part (expected " . 0x18 . " found " . length($args{Struct}) . ")";
    }
    my $self = $class->Alleg::CoreObject::new(@_);
    my $type = $self->param('type');

    if (    $type == AGCEquipmentType_Magazine) {
        $class = 'Alleg::Part::Missile';
    }
    elsif ( $type == AGCEquipmentType_ChaffLauncher) {
        $class = 'Alleg::Part::Chaff';
    }
    elsif ( $type == AGCEquipmentType_Dispenser) {
        $class = 'Alleg::Part::Dispenser';
    }
    else {
        $class = 'Alleg::Part::MiscSpecial';
#        warn "Blessing unknown special part type '$type' ($self->{slot}) as a MiscSpecial";
        # confess "Unknown special part type $type";
    }
    eval "use $class";
    die $@ if $@;
    $self = bless $self, $class;
    return $self;
}
1;
