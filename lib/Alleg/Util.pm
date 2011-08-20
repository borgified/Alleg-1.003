# $Id: Util.pm,v 1.5 2003/01/22 00:56:13 Administrator Exp $
package Alleg::Util;

=head1 NAME

Alleg::Util - Utility functions for use by PerlICE

=head1 SYNOPSIS

use Alleg::Util;

=cut

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
use Carp;

@ISA = qw(Exporter);
@EXPORT = qw(
    fdgetshort  fdgetlong   getshort
    getlong     mkshort     mklong
    adjust_value
);
$VERSION = do { my @r = (q$Revision: 1.5 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

=pod

  $short = getshort($binary);

=cut
  
sub getshort {
    my $buf = shift;
    ($buf) = unpack 's*', $buf;
    return $buf;
}

=pod

  $short = fdgetshort(\*FD);

=cut

sub fdgetshort {
    my $fd = shift;
    return getshort( _readfd($fd, 2) );
}

sub _readfd {
    my ($fd, $bytes) = @_;
    my ($buf, $bytes_read);
    ($bytes_read = read($fd, $buf, $bytes))
        == $bytes or confess "_readfd($fd): $!, bytes read: $bytes_read, expected $bytes";
    return $buf;
}

=pod

  $long = getlong($binary);

=cut
  
sub getlong {
    my $buf = shift;
    ($buf) = unpack 'l*', $buf;
    return $buf;
}

=pod

  $long = fdgetlong(\*FD);

=cut

sub fdgetlong {
    my $fd = shift;
    return getlong( _readfd($fd, 4) );
}

=pod

  my $packed_short = mkshort($number);
  my $packed_long  = mklong($number);

=cut

sub mkshort {
    my $num = shift;
    if (! defined $num) {
        confess "Can not pack undef value";
    }
    else {
        return pack 's', $num;
    }
}

sub mklong {
    my $num = shift;
    if (! defined $num) {
        confess "Can not pack undef value";
    }
    else {
        return pack 'l', $num;
    }
}

=pod

# If $new has a leading +, -, or * the new value will be similarly computed
# against the existing value, otherwise it overwrites it directly.
$new_value = adjust_value($old, $new);
$ten_percent_more = adjust_value($old, '*0.1');

=cut

sub adjust_value {
    my $old     = shift;
    my $new     = shift;

    # Don't play games with refs/objects
    return $new if ref($new);

    my ($action, $value);
    if (($action, $value) = ($new =~ m#^([\+\*/\%\.])(.+)#)) {
        if ($action eq '.') {
            $new = $old . $value;
        }
        elsif ($value =~ /[^.\d]/) {
            confess "ERROR: Can not compute non-numaric value '$value' with action '$action'";
        }
        else {
            if ($action eq '+') {
                $new = $old + $value;
            }
            elsif ($action eq '*') {
                $new = $old * $value;
            }
            elsif ($action eq '/') {
                $new = $old / $value;
            }
            elsif ($action eq '%') {
                $new = $old % $value;
            }
        }
    }
    return $new;
}

1;
__END__

=head1 DESCRIPTION

Utility functions for use by PerlICE

=head1 AUTHOR

Zenin <zenin@rhps.org>

=head1 SEE ALSO

perl(1).

=cut
