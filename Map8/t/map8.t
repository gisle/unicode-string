print "1..2\n";

use Unicode::Map8;

print "MAPS_DIR = $Unicode::Map8::MAPS_DIR\n";

$l1 = Unicode::Map8->new("latin1") || die;
$no = Unicode::Map8->new("no")     || die;

print "not " unless $no->to8($l1->to16("xyzזרו")) eq "xyz{|}";
print "ok 1\n";

print "not " unless $no->recode8($l1, "xyz{|}") eq "xyzזרו";
print "ok 2\n";
