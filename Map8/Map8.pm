package Unicode::Map8;

# Copyright (c) 1998, Gisle Aas.
#
# This library is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

use strict;
use vars qw($VERSION @ISA $DEBUG);

require DynaLoader;
@ISA=qw(DynaLoader);

$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);
$DEBUG++;

bootstrap Unicode::Map8 $VERSION;

sub new
{
    my $class = shift;
    my $self;
    if (@_) {
	$self = Unicode::Map8::_new_file(shift);
    } else {
	$self = Unicode::Map8::_new();
    }
    print "CREATED $self\n" if $DEBUG;
    $self;
}

sub DESTROY
{
    my $self = shift;
    if ($DEBUG) {
	print "DESTROY $self\n";
	$self->fprint(\*STDOUT) if $self->can('fprint');
    }
    $self->_free;
}

1;
