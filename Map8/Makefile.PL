use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	   => 'Unicode::Map8',
    'VERSION_FROM' => 'Map8.pm',
    'LIBS'	   => [''],
    'DEFINE'	   => '-DPERL',
    'INC'	   => '',
    'OBJECT'    => q[Map8$(OBJ_EXT) map8$(OBJ_EXT)],
);
