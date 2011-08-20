# $Id: Core.pm,v 1.11 2003/01/22 00:52:53 Administrator Exp $

=head1 NAME

Alleg::Core - Perl SDK for building Allegiance Game Core (.igc) files

=head1 SYNOPSIS

  use Alleg::Core;
  my $core      = Alleg::Core->new();
  my $core      = Alleg::Core->new( $FILE_HANDLE_TO_IGC );
  my $core      = Alleg::Core->new( Alleg::Globals->new() );
  my $core      = Alleg::Core->new( %new_global_options );
  my $size      = $core->size();
  my $version   = $core->version();
  $core->version($my_version);

  my $igc       = $core->pack(); # you probably want to write this to a .igc file

  my $object    = $core->add_any_type(TypeID => $obj_type, Struct => $struct);
  my $object    = $core->add_generic(TypeID => $obj_type, Struct => $struct);
  $core->set_globals( Alleg::Globals->new() ); # replaces existing Globals object

=cut

package Alleg::Core;

use strict;
use vars qw($VERSION @CORE_TYPES @TYPE_HANDLERS $DEBUG);
$VERSION = do { my @r = (q$Revision: 1.11 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

use Carp;
use Data::Dumper;
use Config qw(%Config);
use POSIX qw(:fcntl_h);

use Alleg::Defaults;
use Alleg::Util;
use Alleg::Constants qw(:agc_object_types @OBJECT_TYPES_REV MAX_UID MAX_DEF);
use Alleg::Globals;
use Alleg::Generic;

use Alleg::Projectile;
use Alleg::Missile;
use Alleg::Chaff;
use Alleg::Mine;
use Alleg::Probe;
use Alleg::Part;
use Alleg::Part::Booster;
use Alleg::Part::Chaff;
use Alleg::Part::Cloak;
use Alleg::Part::Dispenser;
use Alleg::Part::Missile;
use Alleg::Part::Pack;
use Alleg::Part::Shield;
use Alleg::Part::Weapon;
use Alleg::Part::MiscSpecial;
use Alleg::Ship;
use Alleg::Research;
use Alleg::Drone;
use Alleg::Station;
use Alleg::TreasureSet;
use Alleg::Faction;

if (exists $ENV{DEBUG}) {
    $DEBUG = $ENV{DEBUG};
}
else {
    $DEBUG = 0;
}

@CORE_TYPES = qw(
    Projectile  Missile     Chaff
    Mine        Probe       Part
    Ship        Research    Drone
    Station     TreasureSet Faction
);

sub new {
    my $class = shift;
    my $core;

    if (ref $class) {
        # We allow for $core->new() to double as a clone()
        $core->{Globals} = $class->{Globals}->new();
        for my $type (@CORE_TYPES) {
            for my $obj (@{ $class->{$type} }) {
                push @{ $core->{type} }, $obj->new();
            }
        }
        $class = ref($class);
    }
    elsif (@_ && $_[0]->isa('GLOB')) {
        $core = $class->new_from_fh(@_);
    }
    # Normal "blank" core creation
    else {
        if (@_ && $_[0]->isa('Allg::Globals')) {
            $core->{Globals} = shift;
        }
        else {
            $core->{Globals} = Alleg::Globals->new(@_);
        }
        for my $type (@CORE_TYPES) {
            $core->{$type} = [];
        }
    }
    return bless $core, $class;
}

sub new_from_fh {
    my $class   = shift;
    $class      = ref($class) || $class;
    my $fh      = shift;
    my $core    = $class->new();

    $core->version(fdgetlong($fh));
    my $size = fdgetlong($fh) + 8;  # We need real file size, not core size.

    my $last_type   = 0;
    my $total_type  = 0;
    while (tell($fh) < $size) {
        my $obj_type    = fdgetshort($fh);
        my $obj_size    = fdgetlong($fh);
        my $buf;
        my $bytes       = read $fh, $buf, $obj_size;
        $bytes == $obj_size
            or confess "read(): Expected $obj_size bytes, read $bytes bytes";

        if ($obj_type == AGC_Constants) {
            $core->set_globals(Alleg::Globals->new( Struct => $buf) );
        }
        else {
            $core->add_any_type(TypeID => $obj_type, Struct => $buf);
        }

        if ($DEBUG) {
            if ($obj_type == $last_type) {
                # print '.';
                $total_type++;
            }
            elsif ($last_type) {
                # printf "\n%-35s.", $OBJECT_TYPES_REV[$obj_type];
                printf "%-d\n%-35s", $total_type, $OBJECT_TYPES_REV[$obj_type];
                $total_type = 1;
            }
            else {
                printf "%-35s", $OBJECT_TYPES_REV[$obj_type];
                $total_type++;
            }
        }
        $last_type = $obj_type;
    }
    if ($DEBUG) {
        print "$total_type\n";
    }
    return $core;
}

sub size {
    my $core = shift;

    my $size = $core->{Globals}->size();
    $size   += 6; # for object type and size

    for my $type (@CORE_TYPES) {
        for my $obj (@{ $core->{$type} }) {
            $size += $obj->size();
            $size += 6; # for object type and size
        }
    }
    return $size;
}

sub version {
    $_[1]
        ? $_[0]->{Version} = $_[1]
        : $_[0]->{Version}
}

sub pack {
    my $core = shift;
    my $pack = '';
    
    unless (defined $core->version()) {
        confess 'A core version must be set before the core can be packed.  Use "$my_core->version($my_version);" to set it.';
    }

    my $version = $core->version();
    my $size    = $core->size();
    if ($DEBUG) {
        print "----------------------------------------\n";
        printf "%-35s%s\n", "Core version:", $version;
        printf "%-35s%s\n", "Core size:", $size;
        printf "%-35s%d\n", $OBJECT_TYPES_REV[AGC_Constants], 1;
    }

    $pack   .= mklong($version);
    $pack   .= mklong($size);
    $pack   .= $core->{Globals}->pack();

    for my $type (@CORE_TYPES) {
        my $type_id = 'UNKNOWN';
        if (@{ $core->{$type} }) {
            $type_id = $core->{$type}[0]->object_type_id();
        }
        
        if ($DEBUG > 1) {
            $pack .= "\n\n[START:$type/$type_id]";
        }

        for my $obj (@{ $core->{$type} }) {
            if ($DEBUG > 1) {
                $pack .= "\n[NEXT:" . ref($obj) . "]";
            }
            $pack .= $obj->pack();
        }
        if ($DEBUG) {
            printf "%-35s%d\n", $OBJECT_TYPES_REV[$type_id], scalar @{ $core->{$type} };
        }
    }

#    $core->DEBUG_UIDS();

    return $pack;
}

sub DEBUG_UIDS {
    my $core = shift;
    warn "DEBUGGING UIDS";
    for (my $i=1; $i < @{ $core->{UIDS} }; $i++) {
        $core->{UIDS}[$i] ||= [];
        next if (scalar @{ $core->{UIDS}[$i] } == 1);
        printf STDERR "%d (%d)", $i, scalar @{ $core->{UIDS}[$i] };
        my $last_obj = ref $core->{UIDS}[$i][0];
        for my $obj (@{ $core->{UIDS}[$i] }) {
            if (ref ($obj) ne $last_obj) {
                print STDERR ':';
                for my $robj (@{ $core->{UIDS}[$i] }) {
                    my $shit = ref $robj;
                    $shit =~ s/^Alleg::/ /;
                    print STDERR $shit;
                }
                last;
            }
            $last_obj = ref $obj;
        }
        print STDERR "\n";
    }
}

sub add_any_type {
    my $core    = shift;
    my %opts    = @_;
    exists $opts{TypeID}
        or confess __PACKAGE__ . '->add_any_type(): Missing required "TypeID" parameter';
    my $type    = delete $opts{TypeID};
    my $obj;

    if (my $add_method = $TYPE_HANDLERS[ $type ]) {
        $obj = $core->$add_method(%opts);
    }
    else {
        $obj = $core->add_generic(@_);
    }
    return $obj;
}

sub add_generic {
    my $core = shift;
    my $obj = Alleg::Generic->new(@_);
    push @{ $core->{Generic} }, $obj;
    return $obj;
}

sub add_object_as_generic {
    my $core = shift;
    my $type = shift;
    my $obj = Alleg::Generic->new(@_);
    push @{ $core->{$type} }, $obj;
    return $obj;
}

sub set_globals {
    my $core    = shift;
    my $globals = shift;
    if ($globals->isa('Alleg::Globals')) {
        $core->{Globals} = $globals;
    }
    else {
        confess __PACKAGE__ . ": Invalid type: expected 'Alleg::Globals' was given '$globals'";
    }
    return $globals;
}

$TYPE_HANDLERS [ AGC_ProjectileType ]   = \&add_projectile;
$TYPE_HANDLERS [ AGC_MissileType ]      = \&add_missile;
$TYPE_HANDLERS [ AGC_ChaffType ]        = \&add_chaff;
$TYPE_HANDLERS [ AGC_MineType ]         = \&add_mine;
$TYPE_HANDLERS [ AGC_ProbeType ]        = \&add_probe;
$TYPE_HANDLERS [ AGC_PartType ]         = \&add_part;
$TYPE_HANDLERS [ AGC_BucketStart ]      = \&add_ship;
$TYPE_HANDLERS [ AGC_Development ]      = \&add_research;
$TYPE_HANDLERS [ AGC_DroneType ]        = \&add_drone;
$TYPE_HANDLERS [ AGC_StationType ]      = \&add_station;
$TYPE_HANDLERS [ AGC_TreasureSet ]      = \&add_treasure_set;
$TYPE_HANDLERS [ AGC_Civilization ]     = \&add_faction;

sub add_projectile  { my $core = shift; return $core->add_object_as('Projectile',   @_) }
sub add_missile     { my $core = shift; return $core->add_object_as('Missile',      @_) }
sub add_chaff       { my $core = shift; return $core->add_object_as('Chaff',        @_) }
sub add_mine        { my $core = shift; return $core->add_object_as('Mine',         @_) }
sub add_probe       { my $core = shift; return $core->add_object_as('Probe',        @_) }
sub add_part        { my $core = shift; return $core->add_object_as_part(@_); }
sub add_ship        { my $core = shift; return $core->add_object_as('Ship',         @_) }
sub add_research    { my $core = shift; return $core->add_object_as('Research',     @_) }
sub add_drone       { my $core = shift; return $core->add_object_as('Drone',        @_) }
sub add_station     { my $core = shift; return $core->add_object_as('Station',      @_) }
sub add_treasure_set { my $core = shift; return $core->add_object_as('TreasureSet', @_) }
sub add_faction     { my $core = shift; return $core->add_object_as('Faction',      @_) }

sub set_uid {
    my ($core, $type, $obj) = @_;
    my $uid;

# WTF is this line?  Should it be $obj, not $core, and if so should it panic?
#    return unless exists($core->{uid});

    $core->{UIDS}{$type} ||= [];

    # Explicit UID given, or do we make one up on the fly?
    unless ( defined($uid = $obj->param('uid')) ) {
        $uid = $core->get_free_uid($type);
        $obj->param('uid', $uid);
    }

    if (defined $core->{UIDS}{$type}[$uid]) {
        warn "WARNING: Explicitly overwriting existing UID $type/$uid ($core->{UIDS}{$type}[$uid]) with $obj; this core will probably be invalid!";
    }

    $core->{UIDS}{$type}[$uid] = $obj;
    return $uid;
}

sub get_free_uid {
    my ($core, $type) = @_;
    unless (grep /^$type$/, @CORE_TYPES) {
        confess "PANIC: '$type' is not a valid core type.  Must be one of: " . join(", ", @CORE_TYPES);
    }
    for (my $i=1; $i <= MAX_UID; $i++) {
        unless( defined $core->{UIDS}{$type}[$i] ) {
            return $i;
        }
    }
    confess "No $type UIDs are free (max UID " . MAX_UID . "), OMFG your core must be huge!";
}

sub get_free_def {
    my $core = shift;
    for (my $i=1; $i <= MAX_DEF; $i++) {
        if (! defined $core->{DEFS}[$i]) {
            return $i;
        }
    }
    confess "No DEFs are free (max DEF " . MAX_DEF . "), OMFG your core must be huge!";
}

sub add_object_as {
    my $core = shift;
    my $type = shift;
    my $obj_class = "Alleg::$type";
    eval "use $obj_class";
    $@ and die $@;

    my $obj;

    if (@_ == 1) {
        my $new_obj = shift;
        if ($new_obj->isa($obj_class)) {
            $obj = $new_obj;
        }
        else {
            confess __PACKAGE__ . ": Can't add an '$obj' type as an $obj_class";
        }
        $core->set_uid($type, $obj);
        push @{ $core->{$type} }, $obj;
        return $obj;
    }
    else {
        $obj = $obj_class->new(@_);
        $core->set_uid($type, $obj);
        push @{ $core->{$type} }, $obj;
    }

    my %args = @_;
    my $ori_size = length($args{Struct});
    my $obj_size = $obj->size();

    if ($ori_size != $obj_size) {
        warn sprintf("%s: Object size doesn't match original (ori/obj): %d(0x%x)/%d(0x%x)",
            $obj,
            $ori_size, $ori_size,
            $obj_size, $obj_size
        );
        warn "Original struct: '$args{Struct}'";
        for my $field ($obj->pack_order) {
            warn "    $field => '$obj->{$field}'\n";
        }
        die Dumper($obj);
    }
    return $obj;
}

sub add_object_as_part {
    my $core = shift;
    my $obj_class = 'Alleg::Part';

    eval "use $obj_class";              $@ and die;
    eval "use ${obj_class}::Special";   $@ and die;

    my $obj;

    if (@_ == 1) {
        my $new_obj = shift;
        if ($new_obj->isa($obj_class)) {
            $obj = $new_obj;
        }
        else {
            confess __PACKAGE__ . ": Can't add an '$obj' type as an $obj_class";
        }
    }
    else {
        my %args = @_;
        if (length $args{Struct} == 0x18) {
            $obj = Alleg::Part::Special->new(@_);
        }
        else {
            $obj = Alleg::Part->new(@_);
        }
    }

    $core->set_uid('Part', $obj);
    push @{ $core->{Part} }, $obj;
    return $obj;
}

# Danger Will Robinson, Danger!  Ugly Hack Follows!
# $core->export_pice($project_directory)
sub export_pice {
    my $core    = shift;
    my $dir     = shift;
    my $mode    = 0755;
    my $mode_pl = 0644;
    my $core_version = $core->version(); 
    my @my_vars = [ qw($core $igc_file) ];

    if (-e $dir) {
        unless (-d $dir) {
            confess "$dir exists but is not a directory; can't export";
        }
    }
    else {
        mkdir $dir, $mode
            or confess "mkdir($dir, $mode): $!";
    }

    sysopen my $defaults_pl, "$dir/Defaults.pl", O_CREAT|O_TRUNC|O_WRONLY|O_EXCL, $mode
        or confess "open($dir/Defaults.pl): $!";

    sysopen my $core_pl, "$dir/my_core.pl", O_CREAT|O_TRUNC|O_WRONLY|O_EXCL, $mode
        or confess "open($dir/my_core.pl): $!";

    print $core_pl "$Config{startperl} -w\n\n";
    print $core_pl <<"EndOfCoreStart";
#
# Turn on a few sanity checks for Perl
use warnings;       # Tell us if you think we screwed up
# use diagnostics;  # Tell us in detail
use strict;         # Blow up when we do something stupid

use Alleg::Core;    # This is the Big Kahuna
use MyCore;         # This is where we keep our own "globals"

\$|++;

\$igc_file   = 'my_core.igc';    # What file to save our core
\$core = Alleg::Core->new();     # Our core object.  Everything goes into this
\$core->version($core_version);  # Use a different version per release of your core

\$ENV{DEBUG} or print <<"EndOfIntro";
Allegiance Core creation started.

I'm now going to read your type files one by one.  If there are any syntax
errors found perl will throw an exception and this process will stop
(without creating (or overwriting) your allegiance core file).  If you're
new to Perl programming the errors may be confusing.  If so, I suggest
editing this file (my_core.pl) and uncommenting the line at the top which
says, "use diagnostics;".  Simply remove the pound sign (#) from the front
of it. Doing this will cause perl to print out the sections of documentation
relating to the particular error (or warning) type.

And remember...NEVER, EVER write code using MS Word or similar "word
processors".  Use notepad (Wordpad is also acceptable, if you're carful (NO
WORD WRAP, EVER!), but your best bet is to get yourself a good "programming
editor".  I'm a Unix hack, so I'd of course suggest Vim or Emacs (or JOE,
the editor I use), all available free for Windows, but I'm told "The
Programmer's Editor" isn't too bad for Windows users (also free AFAIK).

This intro will stop being displayed as soon as you've learned enough Perl
to know how to remove it yourself. :-)

EndOfIntro

EndOfCoreStart

    foreach my $file ('Defaults', 'Globals', @CORE_TYPES) {
        printf $core_pl "%-24s%s\n", qq(require "$file.pl";), "# Load $file types";
    }

print $core_pl <<"EndOfCoreEnd";

print "Saving your new core to \$igc_file...";
open MY_NEW_CORE, ">\$igc_file"
    or die \$!;
print MY_NEW_CORE \$core->pack();
close MY_NEW_CORE;
print "Done!\\n";
EndOfCoreEnd

    # Write global object build script
    sysopen my $globals, "$dir/Globals.pl", O_CREAT|O_TRUNC|O_WRONLY|O_EXCL, $mode_pl
        or confess "open($dir/Globals.pl): $!";
    print $globals "# Adjust core global values below.  Only one global object per core.\n\n";
    print $globals "use MyCore;\n\n";
    my ($export_globals, $globals_var) = $core->{Globals}->export();

    print $defaults_pl $core->{Globals}->export_defaults();

    push @my_vars, [ $globals_var ];
    print $globals $export_globals;
    print $globals "\$core->set_globals($globals_var);\n\n";
    print $globals "1;\n\n__END__\n";
    close $globals;

    # Write the rest of the build scripts
    for my $type (@CORE_TYPES) {
        sysopen my $type_script, "$dir/$type.pl", O_CREAT|O_TRUNC|O_WRONLY|O_EXCL, $mode_pl
            or confess "open($dir/$type.pl): $!";
        print $type_script "# Adjust $type objects below.\n\n";
        print $type_script "use strict;\n";
        print $type_script "use MyCore;\n";

        my $obj_num = 1;
        my @vars;

        if ( @{ $core->{$type} } ) {
            print $defaults_pl $core->{$type}[0]->export_defaults();
        }

        for my $obj (@{ $core->{$type} }) {
            my $add_method = "add$type";
            $add_method =~ s/([a-z])([A-Z])/${1}_\l$2/g;

            my ($export, $var_name) = $obj->export();
            print $type_script $export;
            print $type_script "\$core->$add_method($var_name); # Object $obj_num\n\n";
            $obj_num++;
            push @vars, $var_name;
        }
        print $type_script "1;\n\n__END__\n";
        close $type_script;
        
        push @my_vars, [ @vars ];
    }

    # Write MyCore.pm
    sysopen my $core_vars, "$dir/MyCore.pm", O_CREAT|O_TRUNC|O_WRONLY|O_EXCL, $mode_pl
        or confess "open($dir/MyCore.pm): $!";
    print $core_vars "# Global variables for my core\n\n";
    print $core_vars <<"EndOfVarsStart";
package MyCore;
require Exporter;
use vars qw(\@ISA \@EXPORT);
\@ISA = qw(Exporter);

my \@vars = qw(
EndOfVarsStart

    for my $var_set (@my_vars) {
        print $core_vars '    ';
        print $core_vars join(' ', @$var_set);
        print $core_vars "\n";
    }

    print $core_vars <<"EndOfVarsEnd";
);

\@EXPORT = \@vars;

1;

__END__

EndOfVarsEnd

    # Write makefile (for those that can use a makefile, like me, others can
    # just call my_core.pl directly.
    sysopen my $makefile, "$dir/Makefile", O_CREAT|O_TRUNC|O_WRONLY|O_EXCL, $mode_pl
        or confess "open($dir/Makefile): $!";
    print $makefile "# Makefile for my_core.igc\n\n";
    print $makefile "all: my_core.igc\n\n";
    print $makefile "my_core.igc: my_core.pl\n";
    my $include = $ENV{TEST_INC} ? "-I$ENV{TEST_INC}" : '';
    print $makefile "\t$Config{perlpath} $include my_core.pl\n\n";
    print $makefile "my_core.pl:";
    print $makefile ' MyCore.pm';
    for my $type ('Defaults', 'Globals', @CORE_TYPES) {
        print $makefile " $type.pl";
    }
    print $makefile "\n\n";
    print $makefile "clean:\n";
    print $makefile "\trm -f my_core.igc\n\n";
    close $makefile;
    
    close $defaults_pl;
}

1;
__END__

=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
