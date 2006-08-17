use 5.008006;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Net::Scan::HTTP::Server::Methods',
    VERSION_FROM      => 'lib/Net/Scan/HTTP/Server/Methods.pm',
    PREREQ_PM         => {
				Class::Accessor::Fast => 0.22,
			},

    ($] >= 5.005 ?
      (ABSTRACT       => 'A simple module for retrieve allowed http methods',
       AUTHOR         => 'Matteo Cantoni <mcantoni@cpan.org>') : ()),
);
