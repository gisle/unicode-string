require v5.5.660;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME	 => 'Convert::UTF',
    VERSION_FROM => 'UTF.pm',
    dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);

