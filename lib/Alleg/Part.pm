package Alleg::Part;

use strict;
use base qw(Alleg::CoreObject);

use Carp;
use Data::Dumper;

use Alleg::Util;
use Alleg::Constants qw(:part_types AGC_PartType);
use Alleg::Defaults;

use vars qw(
    $VERSION
    $PACK_FORMAT    @PACK_ORDER
    $AGC_OBJECT_TYPE
    @PART_CLASSES
    %DEFAULTS
);

$AGC_OBJECT_TYPE = AGC_PartType;

$VERSION = do { my @r = (q$Revision: 1.7 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'a8',   # UCHAR header[8]; // all zero
    'Z13',  # char model[13];
    'a',    # char pad1; // CC
    'Z13',  # char icon[13];
    'Z25',  # char name[25];
    'Z200', # char description[200]; // check len
    's',    # short group;
    'a100', # UCHAR techtree[100];
    'a2',   # char pad2[2]; // CC CC
    'f',    # float stats_s1; // GS1  (-Zenin - wtf is GS1?)
    'S',    # unsigned short suk1; // suk1+suk2 = float = sig modifier (%) (NON SPECS PARTS)
    's',    # unsigned short suk2; // START FOR MISSILE/CHAFF/MINES (SPECS PARTS) = amuont
    'S',    # unsigned short uid; //
    'S',    # unsigned short overriding_uid; // uid of part that overrides this one (-1 if none)
    'S',    # unsigned short type; // 1 = weapon, 2 = shield, 5 = cloak, 7 = after, 6 = default
    'S',    # unsigned short usemask; // = uid a corresponding object for SPECS PARTS
    'Z13',  # char slot[13];
    'a1',   # char pad3[1]; // CC -  END FOR MISSILE/CHAFF/MINES (SPECS PARTS)
    'a2',   # char pad4[2]; // all CC
    'a*',   # !!! CUSTOM PER PART !!!  See subclasses for details
);

#    AGCEquipmentType_ChaffLauncher  = 0,
#    AGCEquipmentType_Weapon         = 1,
#    AGCEquipmentType_Magazine       = 2,
#    AGCEquipmentType_Dispenser      = 3,
#    AGCEquipmentType_Shield         = 4,
#    AGCEquipmentType_Cloak          = 5, or SWARM?
#    AGCEquipmentType_Pack           = 6,
#    AGCEquipmentType_Afterburner    = 7,
#    AGCEquipmentType_MAX            = 8

@PACK_ORDER = qw(
    header      model   pad1        icon    name    description
    group
    techtree    pad2    stats_s1    suk1    suk2    uid
    overriding_uid      type        usemask slot    pad3
    pad4        _CUSTOM
);

sub get_defaults {
    return %DEFAULTS;
}

# SPECIAL! # $PART_CLASSES[  AGCEquipmentType_ChaffLauncher  ] = __PACKAGE__ . '::Chaff';
$PART_CLASSES[  AGCEquipmentType_Weapon         ] = __PACKAGE__ . '::Weapon';
# SPECIAL! # $PART_CLASSES[  AGCEquipmentType_Magazine       ] = __PACKAGE__ . '::Missile';
# SPECIAL! # $PART_CLASSES[  AGCEquipmentType_Dispenser      ] = __PACKAGE__ . '::Dispenser';
$PART_CLASSES[  AGCEquipmentType_Shield         ] = __PACKAGE__ . '::Shield';
$PART_CLASSES[  AGCEquipmentType_Cloak          ] = __PACKAGE__ . '::Cloak';
$PART_CLASSES[  AGCEquipmentType_Pack           ] = __PACKAGE__ . '::Pack';
$PART_CLASSES[  AGCEquipmentType_Afterburner    ] = __PACKAGE__ . '::Booster';

# new() is really a factory which returns an object of one of the above types.
#
# WARNING: Do NOT use this new() for anything other then unpacking raw .igc
# objects!  Use the subclass new()s for general use.
sub new {
    my $class = shift;
    my $self;
    my %args = @_;
    
    my $ori_size = length $args{Struct};

    $self   = $class->SUPER::new(@_);
    $class  = $PART_CLASSES[ $self->param('type') ];

    if (! defined $class) {
        warn "INVALID PART TYPE ($args{Struct})!";
        warn "Part Type: '" . $self->param('type') . "'";
        if (exists $args{Struct}) {
            warn "Length: " . sprintf("%x", length($args{Struct}));
        }
        else {
            warn "No struct?!  Why are we here?!";
        }
    }

    eval "use $class";
    die "PANIC: Can't load part class '$class': $@" if $@;
    $self = bless $self, $class;
    $self->init();
    
    if ($ori_size != $self->size()) {
        die "FATAL: $self: Size mismatch: original $ori_size, object " . $self->size() . ": Original struct: '$args{Struct}', object: " . Dumper($self);
    }
    return $self;
}

# Unpacks single '_CUSTOM' field into it's various parts (differs per subclass)
sub init {
    no strict 'refs';
    my $self = shift;

    my @order   = @{ ref($self) . '::SPECIAL_ORDER' };
    my $format  = ${ ref($self) . '::SPECIAL_FORMAT' };

    @{ $self }{ @order } = unpack ( $format, $self->param('_CUSTOM') );
    delete $self->{_CUSTOM};
    return $self;
}

1;
__END__

=head1 NAME

Alleg::Part - 

=head1 SYNOPSIS

use Alleg::Part;

=cut

=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
