require 5.004;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	   => 'Unicode::Map8',
    'VERSION_FROM' => 'Map8.pm',
    'LIBS'	   => [''],
    'DEFINE'	   => '-DPERL',
    'INC'	   => '',
    'OBJECT'       => q[Map8$(OBJ_EXT) map8$(OBJ_EXT)],
    dist           => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
