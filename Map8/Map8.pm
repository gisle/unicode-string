package Unicode::Map8;

# Copyright (c) 1998, Gisle Aas.
#
# This library is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

use strict;
use vars qw($VERSION @ISA @EXPORT_OK $DEBUG $MAPS_DIR %ALIASES);

require DynaLoader;
@ISA=qw(DynaLoader);

require Exporter;
*import = \&Exporter::import;
@EXPORT_OK = qw(NOCHAR MAP8_BINFILE_MAGIC_HI MAP8_BINFILE_MAGIC_LO);

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
8-bit character sets and 16 bit character sets like Unicode.  The
16-bit strings is assumed to use network byte order.

The following methods are available:

=over 4

=item $m = Unicode::Map8->new( [$charset] )

The object constructor creates new instances of the Unicode::Map8
class.  I takes an optional argument that specify then name of a 8-bit
character set to initialize from.  The argument can also be a the name
of a mapping file.  If the charset/file can not be located, then the
constructor returns I<undef>.

If you omit the argument, then an empty mapping table is constructed.
You must then add mapping pairs to it using the addpair() method
described below.

=item $m->addpair( $u8, $u16 );

Adds a new mapping pair to the mapping object.  It takes two
arguments.  The first is the code value in the 8-bit character set and
the second is the corresponding code value in the 16-bit character
set.  The same codes can be used multiple times (but not the same
pair).  The first definition for a code is the one that is used.

Concider the following example:

  $m->addpair(0x20, 0x0020);
  $m->addpair(0x20, 0x00A0);
  $m->addpair(0xA0, 0x00A0);

It means that the character 0x20 and 0xA0 in the 8-bit charset maps to
themself in the 16-bit set, but in the 16-bit character set 0x0A0 maps
to 0x20.

=item $m->default_to8( $u8 )

=item $m->default_to16( $u16 )

=item $m->nostrict;

All undefined mappings are replaced with the identity mapping.
Undefined character are normally just zapped when converting between
character sets.

=item $m->to8( $ustr );

Converts a 16-bit character string to the corresponding string in the
8-bit character set.

=item $m->to16( $str );

Converts a 8-bit character string to the corresponding string in the
16-bit character set.

=item $m->tou( $str );

Same an to16() but return a Unicode::String object instead of a plain
UCS2 string.

=item $m->recode8($m2, $str);

Map the string $str from one 8-bit character set ($m) to another one
($m2).  Since we know the mappings towards the common 16-bit encoding
we can use this to convert between any of the 8-bit character sets we
know about.

=item $m->to_char16( $u8 )

Maps an 8-bit character code to an 16-bit code.

=item $m->to_char8( $u16 )

Maps a 16-bit character code to an 8-bit code.

=item $m->fprint( FILE );

If the extention is compiled with the -DDEBUGGING option, then this
method is available.  It prints a summary of the content of the
mapping table on the specified file handle.

=back

=head1 BUGS

Does not know how to handle Unicode surugates.

=head1 COPYRIGHT

Copyright 1998 Gisle Aas.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
