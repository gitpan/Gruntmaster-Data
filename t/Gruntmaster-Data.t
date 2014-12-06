#!/usr/bin/perl -w
use v5.14;

use Test::More tests => 13;

BEGIN { use_ok('Gruntmaster::Data') };

my $db = Gruntmaster::Data->connect('dbi:SQLite:dbname=:memory:');
$db->deploy;

$db->users->create({id => 'MGV'});
$db->contests->create({id => 'fc', start => 10, stop => 20, name => 'Finished contest', owner => 'MGV'});
$db->contests->create({id => 'rc', start => 20, stop => 30, name => 'Running contest', owner => 'MGV'});
$db->contests->create({id => 'pc', start => 30, stop => 40, name => 'Pending contest', owner => 'MGV'});

ok $db->contest('pc')->is_pending(25), 'is_pending';
ok !$db->contest('rc')->is_pending(25), '!is_pending';
ok $db->contest('fc')->is_finished(25), 'is_finished';
ok !$db->contest('rc')->is_finished(25), '!is_finished';
ok $db->contest('rc')->is_running(25), 'is_running';

$db->problems->create({id => 'pb', name => 'Problem', generator => 'Undef', runner => 'File', judge => 'Absolute', level => 'beginner', value => 100, owner => 'MGV', statement => '...', testcnt => 1, timeout => 1, private => 0});

ok !$db->problem('pb')->is_private(25), '!is_private';
$db->problem('pb')->update({private => 1});
ok $db->problem('pb')->is_private(25), 'is_private (explicit)';
$db->problem('pb')->update({private => 0});

$db->contest_problems->create({contest => 'pc', problem => 'pb'});
ok $db->problem('pb')->is_private(25), 'is_private (implicit)';
ok $db->problem('pb')->is_in_archive(25), 'is_in_archive';

$db->contest_problems->create({contest => 'rc', problem => 'pb'});
ok $db->problem('pb')->is_private(25), 'is_private (also implicit)';
ok !$db->problem('pb')->is_in_archive(25), '!is_in_archive';

$db->contest_problems->find('rc', 'pb')->delete;
ok $db->problem('pb')->is_in_archive(25), 'is_in_archive (again)';
