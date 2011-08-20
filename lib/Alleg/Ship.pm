package Alleg::Ship;

=head1 NAME

Alleg::Ship - 

=head1 SYNOPSIS

use Alleg::Ship;

=cut

use strict;
use Carp;

use base qw(Alleg::CoreObject);

use Alleg::Util;
use Alleg::Constants qw(
    AGC_BucketStart
    IGC_SHIP_MAX_PARTS
    IGC_SHIP_MAX_USE
    IGC_SHIP_MAX_WEAPONS
);

use enum qw(PART_TYPE_TURRET PART_TYPE_GUN);

use Alleg::Defaults;

use vars qw(
    $VERSION
    %DEFAULTS           %PART_DEFAULTS
    $PACK_FORMAT        @PACK_ORDER         $BASE_PACK_SIZE
    $PART_PACK_FORMAT   @PART_PACK_ORDER    $PART_PACK_SIZE
    $AGC_OBJECT_TYPE
);

$AGC_OBJECT_TYPE = AGC_BucketStart;

$VERSION = do { my @r = (q$Revision: 1.10 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'l',    # AGCMoney cost;
    'a4',   # UCHAR header[4]; // all zero
    'Z13',  # char model[13];
    'a',    # char pad1; // CC
    'Z13',  # char icon[13];
    'Z25',  # char name[25];
    'Z201', # char description[200]; // check len
    # group and zero swapped...not sure why -Zenin
    'a',    # char group;
#    'a',    # BYTE zero;
    'a100', # UCHAR techtree[100];
    'a2',   # char pad2[2]; //00 00
    'f',    # float stats_s1; // mass
    'f',    # float stats_s2; // sig%
    'f',    # float stats_s3; // speed
    'f',    # float stats_s4; // SAX = MaxRollRate in radians
    'f',    # float stats_s5; // SAY = MaxPitchRate in radians
    'f',    # float stats_s6; // SAZ = MaxYawRate in radians
    'f',    # float stats_s7; // SBX = DriftRoll (unit ?)
    'f',    # float stats_s8; // SBY = DriftPitch (unit ?)
    'f',    # float stats_s9; // SBZ = DriftYaw  (unit ?)
    'f',    # float stats_s10; // max thrust
    'f',    # float stats_s11; // STM (side thrust multiplier)
    'f',    # float stats_s12; // RTM (reverse thrust multiplier)
    'f',    # float stats_s13; // scan
    'f',    # float stats_s14; // fuel
    'f',    # float stats_s15; // lock mode
    'f',    # float stats_s16; // scale
    'f',    # float stats_s17; // energy
    'f',    # float stats_s18; // recharge
    'f',    # float stats_s19; // rip time
    'f',    # float stats_s20; // rip cost
    'S',    # unsigned short stats_ss1; // // ammo capacity
    'S',    # unsigned short uid; // confirmed
    'S',    # unsigned short overriding_uid; // -1 if none
    'C',    # UCHAR nb_parts; // part size = 30
    'C',    # UCHAR mnt_nbwpslots;
    'f',    # float stats_hp;
    'a2',   # UCHAR TODO2[2];//1C 02
    'S',    # unsigned short AC;
    'S',    # unsigned short stats_ld1; // missiles capacity
    'S',    # unsigned short stats_ld2; // pack capacity
    'S',    # unsigned short stats_ld3; // CM capacity
    'S' . IGC_SHIP_MAX_PARTS,
            # unsigned short def_loadout[IGCSHIPMAXPARTS];// -1 or part uid
    'S',    # unsigned short hullability;
    'a14',  # UCHAR TODO3[14];// all zero
    'S' . IGC_SHIP_MAX_USE,
            # unsigned short can_use[IGCSHIPMAXUSE]; // usage masks,see IGCShipUseMasks
    'S',    # unsigned short Sound_Interior;
    'S',    # unsigned short Sound_Exterior;
    'S',    # unsigned short Sound_ThrustInterior;
    'S',    # unsigned short Sound_ThrustExterior;
    'S',    # unsigned short Sound_TurnInterior;
    'S',    # unsigned short Sound_TurnExterior;
    'a2',   # UCHAR TODO4[2];// all zero
    'a*',   # SIGCCoreShipMP parts, the total of which is to be determined at runtime
);

$BASE_PACK_SIZE = length CORE::pack(substr($PACK_FORMAT, 0, -2));

$PART_PACK_FORMAT = join('',
    'S',    # unsigned short uk1;
    'S',    # unsigned short uk2;
    'Z13',  # char position[13];
    'a9',   # UCHAR todo[9];//30 00 .. 00
    'S',    # unsigned short part_mask;//usemask of weapon
    'S',    # unsigned short part_type;//1=normal, 0=other player (turret).
);
@PART_PACK_ORDER = qw(
    uk1         uk2
    position
    todo
    part_mask   part_type
);
$PART_PACK_SIZE = length (CORE::pack $PART_PACK_FORMAT);

@PACK_ORDER = qw(
    cost        header      model
        pad1
    icon        name        description
    group
    techtree
        pad2
    mass        sig         speed
    max_roll_rate   max_pitch_rate  max_yaw_rate
    drift_roll      drift_pitch     drift_yaw
    max_thrust
    stm         rtm
    scan        fuel        lock_mode
    scale       energy      recharge    rip_time    rip_cost
    ammo_capacity
    uid         overriding_uid          nb_parts    mnt_nbwpslots
    stats_hp
        TODO2
    ac
    missiles_capacity
    pack_capacity
    cm_capacity
);
for (my $i=1; $i <= IGC_SHIP_MAX_PARTS; $i++) {
    push @PACK_ORDER, sprintf("def_loadout_%02d", $i);
}
push @PACK_ORDER, qw(hullability TODO3);
for (my $i=1; $i <= IGC_SHIP_MAX_USE; $i++) {
    push @PACK_ORDER, sprintf("can_use_%02d", $i);
}
push @PACK_ORDER, qw(
    sound_interior          sound_exterior
    sound_thrust_interior   sound_thrust_exterior
    sound_turn_interior     sound_turn_exterior
    TODO4
    _RAW_PARTS
);

sub size {
    my $self = shift;
    return $BASE_PACK_SIZE + ( $self->param('nb_parts') * $PART_PACK_SIZE );
}

sub new {
    my $class   = shift;
    my %args    = @_;

    my $self    = $class->SUPER::new(@_);

    # Process parts
    if (exists $args{Struct}) {
        my $nb_parts = $self->param('nb_parts');
        for (my $part=0; $part < $nb_parts; $part++) {
            my $part_struct = substr(
                $self->{_RAW_PARTS},
                $part * $PART_PACK_SIZE,
                $PART_PACK_SIZE
            );

            @{ $self->{_PARTS}[$part] }{ @PART_PACK_ORDER }
                = CORE::unpack($PART_PACK_FORMAT, $part_struct);
        }
        delete $self->{_RAW_PARTS};
    }
    return $self;
}

sub pack {
    my $self = shift;

    # We need to take the fake "_RAW_PARTS" pack info
    my $format = substr($self->pack_format(), 0, -2);
    my @order  = $self->pack_order();
    pop @order;

    my $pack = '';
    $pack   .= mkshort($self->object_type_id());
    $pack   .= mklong($self->size());

    # Sanity check
    for my $field (@order) {
        exists $self->{$field}
            or die "$self: Expected field '$field' not found: " . Dumper($self);
        defined $self->{$field}
            or die "$self: Field '$field' exists, but is undefined: " . Dumper($self);
    }

    # Resolve dynamic overriding_uid
    if (exists $self->{overriding_uid}) {
        if (ref $self->{overriding_uid}) {
            defined $self->{overriding_uid}->{uid}
                or confess "PANIC: $self->{overriding_uid}'s uid field is not defined, can't use it for overriding_uid of $self!";
            $self->{overriding_uid} = $self->{overriding_uid}->{uid};
        }
    }

    $pack .= CORE::pack($format, @{ $self }{ @order });

    # Pack up parts
    my $nb_parts = $self->param('nb_parts');
    for (my $part=0; $part < $nb_parts; $part++) {
        $pack .= CORE::pack($PART_PACK_FORMAT, @{ $self->{_PARTS}[$part] }{ @PART_PACK_ORDER });
    }
    return $pack;
}

# $ship->setPart($part_num, { foo => 'bar', fred => 'barny' });
# Note: setPart() does NOT affect ship part count.  Use addPart() for actual
# additions; setPart() is for adjusting existing parts (mostly).
sub setPart {
    my ($self, $part_num, $part_info) = @_;
    my %part_info = (%PART_DEFAULTS, %$part_info);
    if ($part_num > $self->param('nb_parts')) {
        carp "Modifying part $part_num but ship only has " . $self->param('nb_parts') . " parts defined!";
    }
    for my $key (keys %part_info) {
        $self->{_PARTS}[$part_num]{ $key } = $part_info{$key};
    }
    return $self;
}

# $total_parts = $ship->addPart(%part_info);
sub addPart {
    my $self = shift;
    my %part_info = (%PART_DEFAULTS, @_);
    push @{ $self->{_PARTS} }, { %part_info };

    $self->param('nb_parts', '+1');

    # Is this a gun or a turret?
    if ($part_info{part_type} == PART_TYPE_GUN) {
        $self->param('mnt_nbwpslots', '+1');
    }
    return $self;
}

sub export {
    no strict 'refs';
    my $self    = shift;
    my $type    = ref($self);
    my $obj_num = ++${ $type . "::EXPORT_OBJECT_COUNT" };
    my $var_name = $type . "_$obj_num";
    $var_name =~ s/^Alleg::/MY_CORE_/;
    $var_name =~ s/::/_/g;
    $var_name = '$' . $var_name;
    
    my $export = sprintf "my %s = %s->new(\n", $var_name, $type;
    my %fields;
    @fields{ $self->pack_order } = @$self{ $self->pack_order };
    delete $fields{_RAW_PARTS};
    my $techtree = delete $fields{techtree} ? 1 : 0;
    $export .= $self->export_hash(\%fields, 4);
    $export .= ");\n";
    if ($techtree) {
        $export .= $self->export_techtree($var_name);
    }

    my $total_parts = $self->param('nb_parts');
    for (my $part=0; $part < $total_parts; $part++) {
        $export .= "# Note: Normally use addPart() to add parts, not setPart()\n";
        $export .= "$var_name->setPart($part, {\n";
        $export .= $self->export_hash($self->{_PARTS}[$part], 4, %PART_DEFAULTS);
        $export .= "});\n";
    }
    return ($export, $var_name);
}

1;

__END__


=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
mnt_nbwpslots turwepemt2
