package Alleg::Part::Dispenser;

use strict;
use vars qw($VERSION);

use base qw(Alleg::Part::Special);
use Alleg::CoreObject;
use Alleg::Util;
use Alleg::Constants qw(AGC_PartType);
use Alleg::Defaults;

use vars qw(
    $VERSION            $PACK_FORMAT    @PACK_ORDER
    $AGC_OBJECT_TYPE
    $SPECIAL_FORMAT     @SPECIAL_ORDER  %DEFAULTS
);

$AGC_OBJECT_TYPE = AGC_PartType;

$VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf '%d.%03d'.'%02d' x ($#r-1), @r};

$PACK_FORMAT    = $Alleg::Part::Special::PACK_FORMAT;
@PACK_ORDER     = @Alleg::Part::Special::PACK_ORDER;
%DEFAULTS       = %Alleg::Part::Special::DEFAULTS;

sub new {
    goto &Alleg::CoreObject::new;
}

1;
