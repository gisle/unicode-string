package Unicode::Map8;

# Copyright (c) 1998, Gisle Aas.
#
# This library is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

use strict;
use vars qw($VERSION @ISA $DEBUG $MAPS_DIR %ALIASES);

require DynaLoader;
@ISA=qw(DynaLoader);

$VERSION = '0.01';  # $Id$
#$DEBUG++;

bootstrap Unicode::Map8 $VERSION;

$MAPS_DIR;  # where to locate map files
%ALIASES;   # alias names

# Try to locate the maps directory, and read the aliases file
for (split(':', $ENV{MAPS_PATH}),
     (map "$_/Unicode/Map8/maps", @INC),
     "."
    )
{
    if (open(ALIASES, "$_/aliases")) {
	$MAPS_DIR = $_;
	local($_);
	while (<ALIASES>) {
	    next if /^\s*\#/;
	    chomp;
	    my($charset, @aliases) = split(' ', $_);
	    next unless $charset;
	    my $alias;
	    for $alias (@aliases) {
		$ALIASES{$alias} = $charset;
	    }
	}
	close(ALIASES);
	last;
    }
}
$MAPS_DIR ||= ".";

sub new
{
    my $class = shift;
    my $self;
    if (@_) {
	my $file = shift;
	if ($file =~ /\.bin$/) {
	    $self = Unicode::Map8::_new_binfile($file);
	} elsif ($file =~ /\.txt$/) {
	    $self = Unicode::Map8::_new_txtfile($file);
	} else {
	    my $charset = $ALIASES{$file} || $file;
	    $file = "$MAPS_DIR/$charset";
	    $self = Unicode::Map8::_new_binfile("$file.bin") ||
		    Unicode::Map8::_new_txtfile("$file.txt") ||
		    Unicode::Map8::_new_binfile("$file")     ||
		    Unicode::Map8::_new_txtfile("$file");
	}
    } else {
	$self = Unicode::Map8::_new();
    }
    print "CREATED $self\n" if $DEBUG && $self;
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
