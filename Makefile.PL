require 5.002;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME     => 'Unicode',
	VERSION  => '19970704__',
 	dist     => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
