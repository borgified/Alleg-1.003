# $Id: CoreObject.pm,v 1.9 2003/01/14 22:05:45 Administrator Exp $
package Alleg::CoreObject;

=head1 NAME

Alleg::CoreObject - Base class for PerlICE core objects

=head1 SYNOPSIS

  use base qw(Alleg::CoreObject);

  my $obj = Alleg::CoreObject->new();
  my $obj = Alleg::CoreObject->new(Struct => $binary_struct);
  my $obj = $existing->new();

  # Note: also packs in object_type_id() and size()
  my $struct            = $obj->pack();
  my $core_struct_size  = $obj->size();

  my $value = $obj->param('param_name');
  $obj->param(param_name => $some_value);
  $obj->param(
    param1  => $some_value,
    param2  => $other_value,
    [...]
  );

  # used by pack() and friends
  $pack_format = $obj->pack_format();
  @pack_order  = $obj->pack_order();

=cut

use strict;
use vars qw($VERSION @ISA);
$VERSION = do { my @r = (q$Revision: 1.9 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

use base qw(Clone);

use Carp;
use Alleg::Util;
use Data::Dumper qw(Dumper);
use Alleg::Defaults;

sub new {
    my $class   = shift;
    my $self    = {};
    my %opts    = @_;
    my $cloning = 0;

    # Arguments must always come in pairs (ie, named arguments)
    if (@_ % 2) {
        confess "ERROR: Uneven number of arguments: $class: " . Dumper(\@_);
    }

    # Are we cloneing?
    if (ref $class) {
        $self       = $class->clone();
        $class      = ref $class;
        $cloning    = 1;
    }

    $self = bless $self, $class;

    # If given a struct to start from, unpack it as our default values.
    if (exists $opts{Struct}) {
        my $struct = delete $opts{Struct};
        @{ $self }{ $self->pack_order() } = CORE::unpack $self->pack_format(), $struct;
    }
    elsif (! $cloning) {
        $self->init_defaults();
        # @{ $self }{ $self->pack_order() } = ();
    }

    # Allow for reverse mapped dynamic overriding_uid
    my $uid_override = delete $opts{uid_override};

    $self->param(%opts) if %opts; # allow for overrides in all cases

    if (defined $uid_override) {
        ref $uid_override
            or confess "uid_override params must be an object reference!";
        $uid_override->isa(ref($self))
            or confess "Only objects of the same type can override each other! ($self can't override $uid_override)";
        $uid_override->param('overriding_uid', $self);
    }
    return $self;
}

sub get_defaults {
    no strict 'refs';
    my $class   = shift;
    $class      = ref($class) || $class;
    my %defaults = %{ $class . '::DEFAULTS' };
    return %defaults;
}

sub set_defaults {
    no strict 'refs';
    my $self    = shift;
    my %new     = @_;
    my $class   = ref($self) || $self;
    my %defaults = %{ $class . '::DEFAULTS' };
    for my $key (keys %new) {
        if (exists $defaults{$key}) {
            $defaults{$key} = $new{$key};
        }
        else {
            confess "ERROR: $class: Unknown field '$key', can not override default";
        }
    }

    %{ $class . '::DEFAULTS' } = %defaults;
    return $self;
}

sub init_defaults {
    my $self    = shift;
    my $class   = ref($self)
        or confess "PANIC: Can not use init_defaults as a class method";

    @{ $self }{ $self->pack_order() } = ();

    my %defaults = $self->get_defaults()
        or return;

    while (my ($key, $val) = each %defaults) {
        unless (exists $self->{$key}) {
            confess "PANIC: Default key '$key' is not a valid field of $class!  Check \@PACK_ORDER and \%DEFAULTS";
        }
        $self->param($key => $val);
        # $self->{$key} = $val;
    }
    
    return $self;
}

# Generic pack() method for all objects.
sub pack {
    my $self    = shift;
    my $format  = $self->pack_format();
    my @order   = $self->pack_order();

    my $pack    = '';
    $pack       .= mkshort($self->object_type_id());
    $pack       .= mklong($self->size());

    # Sanity check
    for my $field (@order) {
        exists $self->{$field}
            or confess "PANIC: $self: Expected field '$field' not found: " . Dumper($self);
        defined $self->{$field}
            or warn "WARNING: $self: Field '$field' exists, but is undefined: " . Dumper($self);
    }

    # Resolve dynamic overriding_uid
    if (exists $self->{overriding_uid}) {
        if (ref $self->{overriding_uid}) {
            defined $self->{overriding_uid}->{uid}
                or confess "PANIC: $self->{overriding_uid}'s uid field is not defined, can't use it for overriding_uid of $self!";
            $self->{overriding_uid} = $self->{overriding_uid}->{uid};
        }
    }

    eval {
        $pack .= CORE::pack($format, @{ $self }{ @order });
    };
    if ($@) {
        warn $@;
        warn "Format: '$format'";
        warn "Order: '" . join("', ", @order) . "'";
    }
    return $pack;
}

# This is basically a really slow way of doing a C sizeof(), but we need to
# be able to override it anyway for things like ships which vary in size
# based on the number of weapons they have.
sub size {
    no strict 'refs';
    my $self    = shift;
    my $class   = ref($self) || $self;
    my $pack_size = ${ $class . '::PACK_SIZE' };

    if ($pack_size) {
        return $pack_size;
    }
    else {
        return length(CORE::pack($self->pack_format()));
    }
}

sub param {
    my ($self, @params) = @_;
    my $class = ref($self)
        or confess "ERROR: param() can not be used as a class method";
    
    if (@params == 1) {
        exists $self->{$params[0]}
            ? return $self->{$params[0]}
            : confess "ERROR: $class: No such parameter '$params[0]', check \@${class}::PACK_ORDER";
    }
    elsif (@params) {
        my %params = @params;
        for my $param (keys %params) {
            if (exists $self->{$param}) {
                if (my $set = $self->can("_set_$param")) {
                    $self->$set($params{$param});
                }
                else {
                    if (defined $self->{$param}) {
                        $self->{$param} = adjust_value($self->{$param}, $params{$param});
                    }
                    else {
                        $self->{$param} = $params{$param};
                    }
                }
            }
            else {
                confess "ERROR: $class: No such parameter '$param', check \@${class}::PACK_ORDER";
            }
        }
    }
    else {
        confess "ERROR: $class" . "->param(): Invalid usage, see `perldoc " . __PACKAGE__ . "'";
    }
}

# $self->set_techtree($zero_or_400, $one_or_zero, @keys);
sub set_techtree {
    my $self    = shift;
    my $bias    = shift;
    my $value   = shift;
    my @add     = @_;

    my $class   = ref($self)
        or confess "ERROR: set_techtree() can not be used as a class method";

    unless (exists $self->{techtree}) {
        confess "ERROR: Object type $class has no Pre/Def fields (no techtree)";
    }
    unless (defined $self->{techtree}) {
        $self->{techtree} = CORE::pack "a100";
    }
    for my $val (@add) {
        if ($val > 399) {
            confess "ERROR: Attempt to set Pre/Def value higher then max of 399 ($val): " . Dumper($self);
            
        }
        if ($val < 0) {
            confess "ERROR: Attempt to set Pre/Def value lower then min of 0 ($val): " . Dumper($self);
        }
        vec ($self->{techtree}, $val + $bias, 1) = $value;
    }

    return $self;
}

sub set_base_pre_def {
    my $self    = shift;
    my $val     = shift;
    @_ && confess "ERROR: set_base_pre_def() only accepts one value!";
    $self->{pICE_BasePreDef} = $val;
    $self->add_pre($val);
    $self->add_def($val);
    return $self;
}

sub add_pre {
    my $self = shift;
    my @pre;
    for my $pre (@_) {
        if (ref $pre) {
            push @pre, $pre->get_def();
        }
        else {
            push @pre, $pre;
        }
    }
    $self->set_techtree(0, 1, @pre);

    return $self;
}

sub add_def         { my $s=shift; $s->set_techtree(400, 1, @_);         $s }
sub set_pre         { my $s=shift; $s->remove_all_pre(); $s->add_pre(@_);  $s }
sub set_def         { my $s=shift; $s->remove_all_def(); $s->add_def(@_);  $s }
sub remove_pre      { my $s=shift; $s->set_techtree(0,   0, @_);         $s }
sub remove_def      { my $s=shift; $s->set_techtree(400, 0, @_);         $s }
sub remove_all_pre  { my $s=shift; $s->set_techtree(0,   0, 0..399);     $s }
sub remove_all_def  { my $s=shift; $s->set_techtree(400, 0, 0..399);     $s }

sub get_pre {
    my $self    = shift;
    my $techtree= $self->param('techtree');
    my @pre;

    for my $pre (0..399) {
        if (vec($techtree, $pre, 1)) {
            push @pre, $pre;
        }
    }
    return @pre;
}

sub get_def {
    my $self    = shift;
    my $techtree= $self->param('techtree');
    my @def;

    for my $def (400..799) {
        if (vec($techtree, $def, 1)) {
            push @def, $def - 400;
        }
    }
    return @def;
}

sub set_overriding_uid {
    my $self    = shift;
    my $uid     = shift;

    exists $self->{overriding_uid}
        or confess "PANIC: $self: has no overriding_uid field!";

    if (ref $uid) {
        if ($uid->isa(__PACKAGE__)) {
            $uid->isa(ref($self))
                or confess "PANIC: $uid can't override a $self!";
            $self->{uid} = $uid; # We'll resolve the actual uid at pack() time.
        }
        else {
            confess "PANIC: I've no idea how to turn a $uid into a AGC UID";
        }
    }
    else {
        $self->{overriding_uid} = $uid;
    }
    return $self;
}

# We expect all core object classes to define $PACK_FORMAT, 
# @PACK_ORDER, and $AGC_OBJECT_TYPE globals, or else override the following
# methods (or override $class->pack() itself).
sub pack_format {
    no strict   'refs';
    my $self    = shift;
    my $class   = ref($self) || $self;
    my $format  = ${ $class . '::PACK_FORMAT' }
        or confess "PANIC: $class: " . ' does not define a $PACK_FORMAT';
    return $format;
}

sub pack_order {
    no strict   'refs';
    my $self    = shift;
    my $class   = ref($self) || $self;
    my @order   = @{ $class . '::PACK_ORDER' }
        or confess "PANIC: $class: " . ' does not define a @PACK_ORDER';
    for (my $i=0; $i < @order; $i++) {
        defined $order[$i]
            or confess "$class: defineds PACK_ORDER, but pack item $i is undefined";
    }
    return @order;
}

sub object_type_id {
    no strict   'refs';
    my $self    = shift;
    my $class   = ref($self) || $self;
    my $type    = ${ $class . '::AGC_OBJECT_TYPE' }
        or confess "PANIC: $class: " . ' does not define a $AGC_OBJECT_TYPE';
    return $type;
}

sub export {
    no strict 'refs';
    my $self    = shift;
    my $type    = ref($self)
        or confess "ERROR: Can not use export() as a class method";
    my $obj_num = ++${ $type . "::EXPORT_OBJECT_COUNT" };
    my $var_name = $type . "_$obj_num";
    $var_name =~ s/^Alleg::/MY_CORE_/;
    $var_name =~ s/::/_/g;
    $var_name = '$' . $var_name;

    my $export = sprintf "%s = %s->new(\n", $var_name, $type;
    my %fields;
    @fields{ $self->pack_order } = @$self{ $self->pack_order };
    my $techtree = delete $fields{techtree} ? 1 : 0;
    $export .= $self->export_hash(\%fields, 4);
    $export .= ");\n";
    if ($techtree) {
        $export .= $self->export_techtree($var_name);
    }
    return ($export, $var_name);
}

sub export_defaults {
    no strict 'refs';
    my $self    = shift;
    my $type    = ref($self) || $self;
    my %defaults= $type->get_defaults()
        or return '';

    my $export  = sprintf "%s->set_defaults(\n", $type;
    $export .= $type->export_hash(\%defaults, 4, NO_DEFAULTS => 1);
    $export .= ");\n\n";
    return ($export);
}

sub export_techtree {
    my $self    = shift;
    my $var_name= shift;
    my $export = '';

    my @pre = $self->get_pre();
    my @def = $self->get_def();

    if (@pre) {
        $export .= "$var_name->add_pre(" . join(", ", @pre) . ");\n";
    }
    if (@def) {
        $export .= "$var_name->add_def(" . join(", ", @def) . ");\n";
    }
    return $export;
}

# my $perl_code = $obj->export_hash($hashref, $indent_len, %defaults);
sub export_hash {
    my ($self, $hash, $indent, %defaults) = @_;
    my $export = '';
    my $col_width = $self->col_width(keys %$hash);
    unless (%defaults) {
        eval { %defaults = $self->get_defaults(); };
    }
    # Ignore errors, we don't care really if we can't find the defaults,
    # they may not exist

    for my $field (
      sort {
        if ($a =~ /\D/ || $b =~ /\D/ || !defined($a) || !defined($b)) {
          $a cmp $b
        }
        else {
          $a <=> $b
        }
      } keys %$hash
    ) {
        no warnings;
        # Don't write out fields that are the same as default
        unless (
            exists($defaults{$field})
            && ($hash->{$field} eq $defaults{$field})
        ) {
            $export .= sprintf "\%${indent}s\%-${col_width}s => %s,\n", '', $field, quote_safe($hash->{$field});
        }
    }
    return $export;
}

sub quote_safe {
    shift if (ref $_[0] && @_ > 1);
    my $val = shift;
    if (!defined $val) {
        $val = 'undef';
    }
    else {
        $val =~ s{([^\w.`~!@#$%^&*()\-+=\[\]\{\};:'<,>.?/| \t])}{ "\\x" . uc(sprintf('%02x', ord $1)) }eg;

        # Don't quote numeric values
        if ($val =~ /[^\d.]/ || length($val) == 0) {
            $val = qq("$val");
        }
    }
    return $val;
}

# Figure out column lengths to pretty print
sub col_width {
    shift if (ref $_[0]);
    my @fields = @_;
    my $max_len = 0;
    for my $field (@fields) {
        $max_len = length $field if (length $field > $max_len);
    }
    if ($max_len % 4 == 0) {
        $max_len += 4;
    }
    else {
        while ($max_len % 4 != 0) {
            $max_len++;
        }
    }
    return $max_len;
}

1;
__END__

=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
