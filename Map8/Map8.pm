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

#$MAPS_DIR;  # where to locate map files
#%ALIASES;   # alias names

# Try to locate the maps directory, and read the aliases file
for (split(':', $ENV{MAPS_PATH} || ""),
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

sub tou
{
    require Unicode::String;
    my $self = shift;
    Unicode::String::utf16($self->to16(@_));
}

# this should be done in C so that we don't have to allocate and UCS2 string
# during the recoding process.

sub recode8
{
    my $self = shift;
    $_[0]->to8($self->map16($_[1]));
}

1;

__END__

=head1 NAME

Unicode::Map8 - Mapping table between 8-bit chars and Unicode

=head1 SYNOPSIS

 require Unicode::Map8;
 my $no_map = Unicode::Map8->new("ISO646-NO") || die;
 my $l1_map = Unicode::Map8->new("latin1")    || die;

 my $ustr = $no_map->to16("V}re norske tegn b|r {res");
 my $lstr = $l1_map->to8($ustr);
 print "$lstr\n";

=head1 DESCRIPTION

The Unicode::Map8 class implement efficient mapping tables between
8-bit character sets and 16 bit character sets like Unicode.

The following methods are available:

=over 4

=item $m = Unicode::Map->new( [$charset] )

=item $m->addpair( $u8, $u16 );

=item $m->nostrict;

=item $m->to8( $ustr );

=item $m->to16( $str );

=item $m->tou( $str );

=item $m->recode8($m2, $str);

=item $m->fprint( FILE );

=back

=head1 COPYRIGHT

Copyright 1998 Gisle Aas.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
