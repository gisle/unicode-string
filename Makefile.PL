use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'	   => 'Unicode::String',
    'VERSION_FROM' => 'String.pm',
    dist           => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
