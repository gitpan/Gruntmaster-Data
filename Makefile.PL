use 5.014000;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME              => 'Gruntmaster::Data',
	VERSION_FROM      => 'lib/Gruntmaster/Data.pm',
	EXE_FILES         => [ qw/gruntmaster-contest gruntmaster-problem gruntmaster-job/ ],
	ABSTRACT_FROM     => 'lib/Gruntmaster/Data.pm',
	AUTHOR            => 'Marius Gavrilescu <marius@ieval.ro>',
	MIN_PERL_VERSION  => '5.14.0',
	LICENSE           => 'AGPL_3',
	SIGN              => 1,
	PREREQ_PM         => {
		qw/Getopt::Long 0
		   POSIX 0

		   Date::Parse 0
		   File::Slurp 0
		   IO::Prompter 0
		   JSON 0
		   Redis 0
		   Sub::Name 0
		   Term::ANSIColor 0/,
	},
	META_MERGE        => {
		dynamic_config => 0,
		resources      => {
			repository => 'https://git.ieval.ro/?p=gruntmaster-data.git',
		}
	}
);
