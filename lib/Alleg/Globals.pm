package Alleg::Globals;

=head1 NAME

Alleg::Globals - blag, blagh

=head1 SYNOPSIS

use Alleg::Globals;

=cut

use strict;
use Carp;
use Data::Dumper;

use base qw(Alleg::CoreObject);
use Alleg::Util;
use Alleg::Constants qw(AGC_Constants);
use Alleg::Defaults;

use vars qw(
    $VERSION        $AGC_OBJECT_TYPE
    $GLOBALS_FORMAT @GLOBALS_ORDER  $GLOBALS_SIZE
    $DAMAGE_FORMAT  @DAMAGE_ORDER   $DAMAGE_SIZE
    $TOTAL_SIZE
    $TOTAL_GLOBALS  $TOTAL_DAMAGES
);

$AGC_OBJECT_TYPE = AGC_Constants;

# (from corestruct.h)
#   #define IGCNUMC 40
#   typedef struct SIGCCoreConstants // tag=0x22 size=440*4
#   {
#       float constants[IGCNUMC];
#       float damages[20][20];
#   } IGCCoreConstants;

$TOTAL_GLOBALS  = 40;
$TOTAL_DAMAGES  = 20;

@GLOBALS_ORDER = qw(
    SHIP_SPEED      SHIP_ACCELERATION
    SHIP_AGILITY_1  SHIP_AGILITY_2

    STATION_HULL1   STATION_HULL2
    STATION_SHEILD1 STATION_SHIELD2

    SHIP_HULL
    SHIP_SHIELD1    SHIP_SHEILD2
    SENSORS         SIGNATURE
    SHIP_ENERGY
    PW_RANGE        EW_RANGE
    MISSILE_TRACK
    HE3SPEED        HE3YIELD
    UNKNOWN
    RIPCORD
    GUN_DAMAGE
    MISSILE_DAMAGE
    COST
    RESEARCH_TIME
);

# Fill in the rest
for (my $i = @GLOBALS_ORDER; $i < $TOTAL_GLOBALS; $i++) {
    # push @GLOBALS_ORDER, sprintf("GLOBAL_%02i", $i);
    $GLOBALS_ORDER[$i] = sprintf("GLOBAL_%02i", $i);
}

for (my $i = 0; $i < $TOTAL_DAMAGES; $i++) {
    push @DAMAGE_ORDER, sprintf("DAMAGE_%02i", $i);
}

$GLOBALS_FORMAT = 'f' . $TOTAL_GLOBALS;
$GLOBALS_SIZE   = length CORE::pack $GLOBALS_FORMAT;

$DAMAGE_FORMAT  = 'f' . $TOTAL_DAMAGES;
$DAMAGE_SIZE    = length CORE::pack $DAMAGE_FORMAT;
$TOTAL_SIZE     = ($DAMAGE_SIZE * $TOTAL_DAMAGES) + $GLOBALS_SIZE;

sub size { $TOTAL_SIZE }

#$self = {
#    GLOBAL_00 = value,
#    GLOBAL_01 = value,
#    [...]
#    DAMAGE_00 = [
#        value, value, value, value, [...20]
#    ]
#    DAMAGE_01 = [
#        value, value, value, value, [...20]
#    ]
#   [...]
#}

sub new {
    my $class   = shift;
    my %opts    = @_;
    my $self    = {};

    # Are we cloning it?
    if (ref $class) {
        $self   = $class->clone();
        $class  = ref $class;
    }

    $self = bless $self, $class;

    # If given a struct to start from, unpack it as our default values.
    if (exists $opts{Struct}) {
        my $struct = delete $opts{Struct};

        # Globals
        my $globals = substr $struct, 0, $GLOBALS_SIZE;
        @{$self}{ @GLOBALS_ORDER } = CORE::unpack $GLOBALS_FORMAT, $globals;

        # Damage type arrays
        for (
            my ($offset, $i) = ($GLOBALS_SIZE, 0);
            $offset < $TOTAL_SIZE;
            $offset += $DAMAGE_SIZE, $i++
        ) {
            $self->{sprintf("DAMAGE_%02i", $i)} = [
                CORE::unpack $DAMAGE_FORMAT, substr($struct, $offset, $DAMAGE_SIZE)
            ];
        }
    }
    # Plain Defaults
    else {
        @{$self}{ @GLOBALS_ORDER } = ( (1) x $TOTAL_GLOBALS );
        for (my $i=0; $i < $TOTAL_DAMAGES; $i++) {
            $self->{sprintf("DAMAGE_%02i", $i)} = [ (1) x $TOTAL_DAMAGES ];
        }
    }

    $self->param(%opts) if %opts; # Allow for overrides

    return $self;
}

# set_damage($dmg_type_id, $ac_id => $value, $ac_id => $value);
sub set_damage {
    my $self    = shift;
    my $dmg_id  = shift;
    if ($dmg_id >= $TOTAL_DAMAGES) {
        confess "ERROR: Damage ID $dmg_id attempted, but max damage type ID is " . ($TOTAL_DAMAGES -1);
    }
    $dmg_id     = sprintf("DAMAGE_%02i", $dmg_id);
    my %ac      = @_;
    for my $key (keys %ac) {
        $self->{$dmg_id}[$key] = adjust_value($self->{$dmg_id}[$key] => $ac{$key});
    }
    return $self;
}

sub pack {
    my $self = shift;
    my $pack = '';
    $pack   .= mkshort($self->object_type_id());
    $pack   .= mklong($self->size());
    $pack   .= CORE::pack $GLOBALS_FORMAT, @{$self}{ @GLOBALS_ORDER };
    for (my $i=0; $i < $TOTAL_DAMAGES; $i++) {
        $pack .= CORE::pack $DAMAGE_FORMAT, @{ $self->{ sprintf("DAMAGE_%02i", $i) } }
    }
    return $pack;
}

sub export {
    my $self    = shift;
    my $var_name= '$Globals';
    my $export  = "my $var_name = Alleg::Globals->new(\n";

    my %globals;
    @globals{ @GLOBALS_ORDER } = @$self{ @GLOBALS_ORDER };
    $export .= $self->export_hash(\%globals, 4);
    $export .= ");\n";

    for (my $dmg=0; $dmg < $TOTAL_DAMAGES; $dmg++) {
        my $dmg_name = sprintf("DAMAGE_%02i", $dmg);
        $export .= "$var_name->set_damage($dmg,\n";
        my %ac;
        for (my $ac=0; $ac < $TOTAL_DAMAGES; $ac++) {
            unless ($self->{$dmg_name}[$ac] == 1) {
                $ac{$ac} = $self->{$dmg_name}[$ac];
            }
        }
        $export .= $self->export_hash(\%ac, 4, NO_DEFAULTS => 1);
        $export .= ");\n";
    }
    return ($export, $var_name);
}

$VERSION = do { my @r = (q$Revision: 1.5 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

1;
__END__

=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
