use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	   => 'Unicode::Map8',
    'VERSION_FROM' => 'Map8.pm',
    'LIBS'	   => [''],      # e.g., '-lm' 
    'DEFINE'	   => '-DPERL',  # e.g., '-DHAVE_SOMETHING' 
    'INC'	   => '',        # e.g., '-I/usr/include/other' 
    'OBJECT'    => q[Map8$(OBJ_EXT) map8$(OBJ_EXT)],
);
