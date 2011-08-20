package Alleg::TreasureSet;

=head1 NAME

Alleg::TreasureSet - 

=head1 SYNOPSIS

use Alleg::TreasureSet;

=cut

use strict;
use Carp;

use base qw(Alleg::CoreObject);

use Alleg::Util;
use Alleg::Constants qw(AGC_TreasureSet);
use Alleg::Defaults;

use vars qw(
    $VERSION
    $PACK_FORMAT        @PACK_ORDER
    $AGC_OBJECT_TYPE    %DEFAULTS           $BASE_PACK_SIZE
    $CHANCE_PACK_SIZE
    $CHANCE_PACK_FORMAT @CHANCE_PACK_ORDER
);

$AGC_OBJECT_TYPE = AGC_TreasureSet;

$VERSION = do { my @r = (q$Revision: 1.4 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT = join('',
    'a26',  # char name[26];
    'S',    # WORD uid;
    'S',    # WORD count;
    'S',    # WORD uk; //= 200
    'a*',   # IGCCoreTreasureChance *ChanceEntries;
);

$BASE_PACK_SIZE = length CORE::pack(substr($PACK_FORMAT, 0, -2));

$CHANCE_PACK_FORMAT = join('',
    'S',    # WORD uid;
    'C',    # BYTE Code; // 1-> uid = part uid,
            # 2-> uid = 31 for powerup,
            # 4-> uid = amount of $
    'C',    # BYTE Chance;
);

@CHANCE_PACK_ORDER = qw(
    chance_uid code    chance
);

$CHANCE_PACK_SIZE = length(CORE::pack $CHANCE_PACK_FORMAT);

@PACK_ORDER = qw(
    name    uid
    count   uk
    _RAW_CHANCES
);

sub size {
    my $self = shift;
    return $BASE_PACK_SIZE + ( $self->param('count') * $CHANCE_PACK_SIZE );
}

sub new {
    my $class   = shift;
    my %args    = @_;

    my $self    = $class->SUPER::new(@_);

    # Process chances
    if (exists $args{Struct}) {
        my $count = $self->param('count');
        for (my $chance=0; $chance < $count; $chance++) {
            my $chance_struct = substr(
                $self->{_RAW_CHANCES},
                $chance * $CHANCE_PACK_SIZE,
                $CHANCE_PACK_SIZE
            );

            @{ $self->{_CHANCES}[$chance] }{ @CHANCE_PACK_ORDER }
                = CORE::unpack($CHANCE_PACK_FORMAT, $chance_struct);
        }
        delete $self->{_RAW_CHANCES};
    }
    return $self;
}

sub pack {
    my $self = shift;

    # We need to take the fake "_RAW_CHANCES" pack info
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

    $pack .= CORE::pack($format, @{ $self }{ @order });

    # Pack up chances
    my $count = $self->param('count');
    for (my $chance=0; $chance < $count; $chance++) {
        $pack .= CORE::pack($CHANCE_PACK_FORMAT, @{ $self->{_CHANCES}[$chance] }{ @CHANCE_PACK_ORDER });
    }
    return $pack;
}

# $treasure->setChance($chance_num, { foo => 'bar', fred => 'barny' });
# Note: setChance() does NOT affect treasure chance count.  Use addChance() for actual
# additions; setChance() is for adjusting existing chances (mostly).
sub setChance {
    my ($self, $chance_num, $chance_info) = @_;
    if ($chance_num > $self->param('count')) {
        warn "Modifying chance $chance_num but treasure only has " . $self->param('count') . " chances defined!";
    }
    for my $key (keys %$chance_info) {
        $self->{_CHANCES}[$chance_num]{ $key } = $chance_info->{$key};
    }
}

# $total_chances = $treasure->addChance(\%chance_info);
sub addChance {
    my ($self, $chance_info) = @_;
    push @{ $self->{_CHANCES} }, { %$chance_info };

    my $chance_count = $self->param('count');
    $chance_count++;
    $self->param('count', $chance_count);
    return $chance_count;
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
    delete $fields{_RAW_CHANCES};
    $export .= $self->export_hash(\%fields, 4);
    $export .= ");\n";

    my $total_chances = $self->param('count');
    for (my $chance=0; $chance < $total_chances; $chance++) {
        $export .= "# Note: Normally use addChance() to add Chancess, not setChance()\n";
        $export .= "$var_name->setChance($chance, {\n";
        $export .= $self->export_hash($self->{_CHANCES}[$chance], 4);
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
