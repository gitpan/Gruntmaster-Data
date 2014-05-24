#!/usr/bin/perl -w
use v5.14;

use Test::More tests => 13;
use File::Temp qw/tempdir/;
use Config;

use Gruntmaster::Data;

my $perl = $Config{perlpath} . $Config{_exe};
my $dir = tempdir CLEANUP => 1;
$ENV{GRUNTMASTER_DSN} = "dbi:SQLite:dbname=$dir/testdb";

our $db;

sub withdb (&) {
	local $db = Gruntmaster::Data->connect($ENV{GRUNTMASTER_DSN});
	shift->()
}

withdb { $db->deploy };

my $pipe;

open $pipe, '|$perl gruntmaster-contest add ct';
print $pipe <<'';
My cool contest
MGV
2014-01-01 00:00Z
2014-01-01 05:00Z

close $pipe;

withdb {
	subtest 'gruntmaster-contest add' => sub {
		plan tests => 5;
		my $ct = $db->contest('ct');
		ok $ct, 'contest exists';
		is $ct->name, 'My cool contest', 'contest name';
		is $ct->owner->id, 'MGV', 'contest owner';
		is $ct->start, 1388534400, 'contest start';
		is $ct->stop, 1388534400 + 5 * 60 * 60, 'contest stop';
	}
};

is `$perl gruntmaster-contest get ct owner`, "MGV\n", 'gruntmaster-contest get';
system $perl, 'gruntmaster-contest', 'set', 'ct', 'owner', 'nobody';
withdb { is $db->contest('ct')->owner->id, 'nobody', 'gruntmaster-contest set' };

withdb { $db->contests->create({id => 'dummy', name => 'Dummy contest', owner => 'MGV', start => 0, stop => 1}) };
my @list = sort `$perl gruntmaster-contest list`;
chomp @list;
my @list2 = withdb { map { $_->id } $db->contests->all };
is_deeply \@list, [ sort @list2 ], 'gruntmaster-contest list';

system $perl, 'gruntmaster-contest', 'rm', 'dummy';
withdb { ok !$db->contest('dummy'), 'gruntmaster-contest rm' };

open $pipe, '|$perl gruntmaster-problem add pb';
print $pipe <<'';
Test problem
n
ct
Marius Gavrilescu
Smaranda Ciubotaru
MGV
b
gruntmaster-problem
c
a
a
3
1
100
Ok
Ok
Ok

close $pipe;

withdb {
	subtest 'gruntmaster-problem add' => sub {
		plan tests => 13;
		my $pb = $db->problem('pb');
		ok $pb, 'problem exists';
		is $pb->name, 'Test problem', 'name';
		is $pb->author, 'Marius Gavrilescu', 'author';
		is $pb->writer, 'Smaranda Ciubotaru', 'statement writer';
		is $pb->owner->id, 'MGV', 'owner';
		is $pb->level, 'easy', 'level';
		is $pb->generator, 'Undef', 'generator';
		is $pb->runner, 'File', 'runner';
		is $pb->judge, 'Absolute', 'judge';
		is $pb->testcnt, 3, 'test count';
		is $pb->timeout, 1, 'time limit';
		is $pb->olimit, 100, 'output limit';
		ok $db->contest_problems->find('ct', 'pb'), 'is in contest';
	}
};

is `$perl gruntmaster-problem get pb author`, "Marius Gavrilescu\n", 'gruntmaster-problem get';
system $perl, 'gruntmaster-problem', 'set', 'pb', 'owner', 'nobody';
withdb { is $db->problem('pb')->owner->id, 'nobody', 'gruntmaster-problem set' };

withdb { $db->problems->create({id => 'dummy', name => 'Dummy', generator => 'Undef', runner => 'File', judge => 'Absolute', level => 'beginner', owner => 'MGV', statement => '...', testcnt => 1, timeout => 1}) };

@list = sort `$perl gruntmaster-problem list`;
chomp @list;
@list2 = withdb { map { $_->id } $db->problems->all };
is_deeply \@list, [ sort @list2 ], 'gruntmaster-problem list';

system $perl, 'gruntmaster-problem', 'rm', 'dummy';
withdb { ok !$db->problem('dummy'), 'gruntmaster-problem rm' };

withdb { $db->jobs->create({id => 1, date => 1, extension => '.ext', format => 'CPP', problem => 'pb', source => '...', owner => 'MGV'}) };

is `$perl gruntmaster-job get 1 format`, "CPP\n", 'gruntmaster-job get';
system $perl, 'gruntmaster-job', 'set', 1, 'format', 'PERL';
withdb { is $db->job(1)->format, 'PERL', 'gruntmaster-job set' };

system $perl, 'gruntmaster-job', 'rm', 1;
withdb { ok !$db->job(1), 'gruntmaster-job rm' };
