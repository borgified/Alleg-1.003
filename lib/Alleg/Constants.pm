package Alleg::Constants;

=head1 NAME

Alleg::Constants - PerlICE Constants

=head1 SYNOPSIS

use Alleg::Constants;

=cut

use strict;
use vars qw(
    $VERSION            @ISA
    @EXPORT             @EXPORT_OK      %EXPORT_TAGS
    @ARMOR_CLASSES
    @OBJECT_TYPES       @OBJECT_TYPES_REV
    @PART_TYPES         @PART_TYPES_REV
    @STATION_BUILDON    @STATION_TYPES  @STATION_ABILITIES
    @HULL_ABILITIES     @MISSILE_ABILITIES
    @AI_TYPES
);

$VERSION = do { my @r = (q$Revision: 1.5 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};
require Exporter;

@ISA        = qw(Exporter);
@EXPORT     = qw(MAX_UID MAX_DEF);
$EXPORT_TAGS{armor_classes}     = \@ARMOR_CLASSES;
$EXPORT_TAGS{agc_object_types}  = \@OBJECT_TYPES;
$EXPORT_TAGS{part_types}        = \@PART_TYPES;
$EXPORT_TAGS{base_buildon}      = \@STATION_BUILDON;
$EXPORT_TAGS{station_types}     = \@STATION_TYPES;
$EXPORT_TAGS{station_abilities} = \@STATION_ABILITIES;
$EXPORT_TAGS{hull_abilities}    = \@HULL_ABILITIES;
$EXPORT_TAGS{missile_abilities} = \@MISSILE_ABILITIES;
$EXPORT_TAGS{ai_types}          = \@AI_TYPES;

use constant MAX_UID    => 400;
use constant MAX_DEF    => 400;

@AI_TYPES = qw(
    AI_TYPE_MINER
    AI_TYPE_WINGMAN
    AI_TYPE_LAYER
    AI_TYPE_CON
    AI_TYPE_CARRIER
);
use constant AI_TYPE_MINER      => 0;
use constant AI_TYPE_WINGMAN    => 2;
use constant AI_TYPE_LAYER      => 5;
use constant AI_TYPE_CONSTRUCTOR=> 6;
use constant AI_TYPE_CARRIER    => 9;

@MISSILE_ABILITIES = qw(
    MISSILE_ABILITY_NONE
    MISSILE_ABILITY_BASE_CAPTURE
    MISSILE_ABILITY_RESONATOR
);
use enum ':=0', @MISSILE_ABILITIES;

@HULL_ABILITIES = qw(
    HULL_ABILITY_BOARD
    HULL_ABILITY_RESCUE
    HULL_ABILITY_LIFEPOD
    HULL_ABILITY_NO_PICKUP
    HULL_ABILITY_NO_EJECTION
    HULL_ABILITY_NO_RIPCORD
    HULL_ABILITY_IS_RIPCORD
    HULL_ABILITY_IS_FIGHTER
    HULL_ABILITY_IS_CAPITAL
    HULL_ABILITY_F2
    HULL_ABILITY_IS_DOCK
    HULL_ABILITY_F8
    HULL_ABILITY_IS_SMALL_RIPCORD
    HULL_ABILITY_IS_MINER
    HULL_ABILITY_IS_CONSTRUCTOR
);
use enum 'BITMASK:', @HULL_ABILITIES;

@STATION_ABILITIES = qw(
    STATION_ABILITY_MINER_UNLOAD
    STATION_ABILITY_STARTING_BASE
    STATION_ABILITY_RESTART
    STATION_ABILITY_IS_RIPCORD
    STATION_ABILITY_CAN_CAPTURE
    STATION_ABILITY_CAN_LAND
    STATION_ABILITY_CAN_REPAIR
    STATION_ABILITY_CAN_EXIT
    STATION_ABILITY_RELOAD
    STATION_ABILITY_FLAG_WIN
    STATION_ABILITY_FLAG_PEDESTAL
    STATION_ABILITY_FLAG_PEDESTAL2
    STATION_ABILITY_CAN_LAND_CAPITAL
    STATION_ABILITY_RESCUE
    STATION_ABILITY_RESCUE_ANY
);
use enum 'BITMASK:', @STATION_ABILITIES;
    
@STATION_TYPES = qw(
    STATION_TYPE_GARRISON
    STATION_TYPE_OUTPOST
    STATION_TYPE_SHIPYARD
    STATION_TYPE_TELEPORT
    STATION_TYPE_REFINERY
    STATION_TYPE_EXPANSION
    STATION_TYPE_SUPREMACY
    STATION_TYPE_TACTICAL
    STATION_TYPE_PLATFORM
    STATION_TYPE_URANIUMMINE
    STATION_TYPE_CARBONMINE
    STATION_TYPE_SILICONMINE
);
use enum @STATION_TYPES;

@STATION_BUILDON = qw(
    STATION_BUILDON_HELIUM
    STATION_BUILDON_UNKNOWN
    STATION_BUILDON_THORIUM
    STATION_BUILDON_ASTERIOD
    STATION_BUILDON_URANIUM
    STATION_BUILDON_SILICON
    STATION_BUILDON_CARBON
);
use enum 'BITMASK:', @STATION_BUILDON;

@ARMOR_CLASSES = qw(
    AC_ASTEROID             AC_LIGHT                AC_MEDIUM
    AC_HEAVY                AC_EXTRA_HEAVY          AC_UTILITY
    AC_MINOR_BASE_HULL      AC_MAJOR_BASE_HULL      AC_LT_AND_MED_SHEILD
    AC_MINOR_BASE_SHEILD    AC_MAJOR_BASE_SHEILD    AC_PARTS
    AC_LT_BASE_HULL         AC_LT_BASE_SHIELD       AC_LARGE_SHIELD
    AC_15                   AC_16                   AC_17
    AC_18                   AC_19
);
use enum @ARMOR_CLASSES;

# AGC_ChaffType = 36 (wrong) in AGM
# AGCObjectType_Invalid=-1
use enum qw(:AGC_
    ModelBegin=0
    Ship=0
        Station=1   Missile     Mine        Probe       Asteroid
        Projectile  Warp        Treasure    Buoy        Chaff
    BuildingEffect=11
    ModelEnd=11
        Side=12     Cluster     Bucket
    PartBegin=15
    Weapon=15
        Shield=16   Cloak       Pack        Afterburner
    LauncherBegin=20
    Magazine=20

    Dispenser=21
    LauncherEnd=21
    PartEnd=21

    StaticBegin=22
    ProjectileType=22
        MissileType=23          MineType    ProbeType   ChaffType
        Civilization            TreasureSet
    BucketStart=29
    HullType=29
        PartType=30 StationType Development
    DroneType=33
    BucketEnd=33
    StaticEnd=33
    Constants=34
    AdminUser=35
    AGCObjectType_Max=36
    Any_Objects=36
);

@OBJECT_TYPES = qw(
    AGCObjectType_Invalid   AGC_ModelBegin      AGC_Ship            AGC_Station
    AGC_Missile             AGC_Mine            AGC_Probe           AGC_Asteroid
    AGC_Projectile          AGC_Warp            AGC_Treasure        AGC_Buoy
    AGC_Chaff               AGC_BuildingEffect  AGC_ModelEnd        AGC_Side
    AGC_Cluster             AGC_Bucket          AGC_PartBegin       AGC_Weapon
    AGC_Shield              AGC_Cloak           AGC_Pack            AGC_Afterburner
    AGC_LauncherBegin       AGC_Magazine        AGC_Dispenser       AGC_LauncherEnd
    AGC_PartEnd             AGC_StaticBegin     AGC_ProjectileType  AGC_MissileType
    AGC_MineType            AGC_ProbeType       AGC_ChaffType       AGC_Civilization
    AGC_TreasureSet         AGC_BucketStart     AGC_HullType        AGC_PartType
    AGC_StationType         AGC_Development     AGC_DroneType       AGC_BucketEnd
    AGC_StaticEnd           AGC_Constants       AGC_AdminUser       AGCObjectType_Max
    AGC_Any_Objects
);

@OBJECT_TYPES_REV = qw(
    ModelBegin/Ship
        Station     Missile Mine        Probe   Asteroid
        Projectile  Warp    Treasure    Buoy    Chaff
    BuildingEffect/ModelEnd
        Side        Cluster Bucket
    PartBegin/Weapon
        Shield      Cloak   Pack        Afterburner
    LauncherBegin/Magazine
    Dispenser/LauncherEnd/PartEnd
    StaticBegin/ProjectileType
        MissileType MineType            ProbeType
        ChaffType   Civilization        TreasureSet
    BucketStart/HullType
        PartType    StationType         Development
    DroneType/BucketEnd/StaticEnd
    Constants
    AdminUser
    AGCObjectType_Max/Any_Objects
);

BEGIN {
    @PART_TYPES = qw(
        AGCEquipmentType_ChaffLauncher  AGCEquipmentType_Weapon
        AGCEquipmentType_Magazine       AGCEquipmentType_Dispenser
        AGCEquipmentType_Shield         AGCEquipmentType_Cloak
        AGCEquipmentType_Pack           AGCEquipmentType_Afterburner
        AGCEquipmentType_MAX
    );
}
use enum @PART_TYPES;

@PART_TYPES_REV = (
    'Counter(AGCEquipmentType_ChaffLauncher)',  'undef 1(AGCEquipmentType_Weapon)',
    'Missile(AGCEquipmentType_Magazine)',       'Pack(AGCEquipmentType_Dispenser)',
    'Shield(AGCEquipmentType_Shield)',          'Cloak(AGCEquipmentType_Cloak)',
    'undef 6(AGCEquipmentType_Pack)',           'Afterburner(AGCEquipmentType_Afterburner)',
    'MAX(AGCEquipmentType_MAX)',
);

# misc
use enum qw(
    IGC_SHIP_MAX_PARTS=14
    IGC_SHIP_MAX_USE=8
    IGC_SHIP_MAX_WEAPONS=20
);

@EXPORT_OK  = (
    @ARMOR_CLASSES,         @OBJECT_TYPES,      '@OBJECT_TYPES_REV',
    @PART_TYPES,            '@PART_TYPES_REV',
    @STATION_BUILDON,       @STATION_TYPES,     @STATION_ABILITIES,     @HULL_ABILITIES,
    @MISSILE_ABILITIES,
    'IGC_SHIP_MAX_PARTS',   'IGC_SHIP_MAX_USE', 'IGC_SHIP_MAX_WEAPONS'
);

1;
__END__


=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
