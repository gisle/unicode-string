package Unicode::Map8;

# Copyright (c) 1998, Gisle Aas.

use strict;
use vars qw($VERSION @ISA);

require DynaLoader;
@ISA=qw(DynaLoader);

$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

bootstrap Unicode::Map8 $VERSION;

1;
