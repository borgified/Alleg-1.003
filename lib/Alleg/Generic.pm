package Alleg::Generic;

=head1 NAME

Alleg::Generic - PerlICE Generic object type (debug only)

=head1 SYNOPSIS

use Alleg::Generic;

=cut

use strict;
use vars qw($VERSION @PACK_ORDER);
use base qw(Alleg::CoreObject);
use Alleg::Defaults;

use Carp;

$VERSION    = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};
@PACK_ORDER = qw(RAW);

sub new {
    my $class = shift;
    my $self;
    if (ref $class) {
        $self = bless $class->clone(), ref $class;
    }
    else {
        my %opts    = @_;
        $self       = bless {}, $class;
        $self->{RAW}= delete $opts{Struct}
            or confess __PACKAGE__ . ': Struct not found: Usage: new(Struct => $struct, TypeID => $id)';
        $self->{TypeID} = delete $opts{TypeID}
            or confess __PACKAGE__ . ': TypeID not found: Usage: new(Struct => $struct, TypeID => $id)';
        if (%opts) {
            confess __PACKAGE__ . ': Unknown parameters: "' . join('", "', sort keys %opts) . '"';
        }
        $self->{PackFormat} = 'a' . length($self->{RAW});
    }
    return $self;
}

sub object_type_id  { $_[0]->{TypeID} }
sub pack_format     { $_[0]->{PackFormat} }
sub param {
    my $self = shift;
    warn __PACKAGE__ . ': WARNING: modifying parameters of Generic objects may be hazardous to your core!';
    return $self->SUPER::param(@_);
}

1;
__END__

=head1 DESCRIPTION

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
