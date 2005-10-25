# Process the UnicodeData.txt into a format suitable for Unicode::CharName

while (<>) {
    chomp;
    my @d = split(/;/, $_);
    print "$d[0] $d[1]\n";
}
