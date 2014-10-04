use 5.014000;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME              => 'Gruntmaster::Data',
	VERSION_FROM      => 'lib/Gruntmaster/Data.pm',
	ABSTRACT_FROM     => 'lib/Gruntmaster/Data.pm',
	AUTHOR            => 'Marius Gavrilescu <marius@ieval.ro>',
	EXE_FILES         => [qw/gruntmaster-problem gruntmaster-contest gruntmaster-job/],
	MIN_PERL_VERSION  => '5.14.0',
	LICENSE           => 'perl',
	SIGN              => 1,
	PREREQ_PM         => {
		qw/Getopt::Long 0
		   PerlX::Maybe 0
		   POSIX 0
		   Term::ANSIColor 0

		   Authen::Passphrase 0
		   Authen::Passphrase::BlowfishCrypt 0
		   Date::Parse 0
		   DBIx::Class 0
		   File::Slurp 0
		   IO::Prompter 0
		   Lingua::EN::Inflect 0
		   JSON::MaybeXS 0
		   PerlX::Maybe 0
		   Sub::Name 0/,
	},
	BUILD_REQUIRES    => {
		qw/DBD::SQLite 0
		   SQL::Translator 0/,
	},
	META_MERGE        => {
		dynamic_config => 0,
		resources      => {
			repository => 'https://git.ieval.ro/?p=gruntmaster-data.git',
		}
	}
);
