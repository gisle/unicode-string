package Convert::UTF;
use XSLoader ();

$VERSION = "0.01";
XSLoader::load 'Convert::UTF', $VERSION;

1;

__END__

=head1 DESCRIPTION

Functions to convert between UTF8 encoded strings and internal perl
strings.  UTF8 encoded strings only contain characters <= 255 and with
has certain demands on well-formedness for sequences of 8-bit chars.
Perl strings have characters with ordinal value above 255.

The following conversion routines are available:

=over

=item encode_utf8( EXPR )

This function takes a string as argument and returns an UTF8 encoded
version of the same string.  If called in void context, it will encode
the string in-place.

=item decode_utf8( EXPR )

This function takes a UTF8-string as argument and tries to decode it.
It does the opposite conversion of utf8::encode(), but might fail for
strings that are not valid UTF8.  If called in void context, it will
decode the string in-place.

=item is_valid_utf8( EXPR )

This function will return a TRUE value if EXPR is a valid UTF8.  Valid
UTF8-strings can be decoded without errors.

=back
