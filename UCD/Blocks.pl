# Process the Blocks.txt into a format suitable for Unicode::CharName

while (<>) {
    if (/^([\da-f]+)\.\.([\da-f]+);\s+(.*)/i) {
	print "  [0x$1, 0x$2 => '$3'],\n";
    }
}
