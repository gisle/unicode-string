print "1..2\n";

# Test Unicode::Map (Martin Schwartz' module) compatibility

use Unicode::Map8;

$m = Unicode::Map8->new({ID => "ISO-8859-1"});

$u = $m->to_unicode("abc..���");

print "not " unless $u eq "\0a\0b\0c\0.\0.\0�\0�\0�";
print "ok 1\n";

print "not " unless $m->from_unicode($u) eq "abc..���";
print "ok 2\n";
