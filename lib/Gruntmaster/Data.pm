package Gruntmaster::Data;
use v5.14;
use warnings;
use parent qw/Exporter/;

use JSON qw/encode_json decode_json/;
use Redis;
use Sub::Name qw/subname/;

our $VERSION = '5999.000_001';

our $contest;
my $redis = Redis->new;
my $pubsub = Redis->new;

sub dynsub{
	our ($name, $sub) = @_;
	no strict 'refs';
	*$name = subname $name => $sub
}

BEGIN {
	for my $cmd (qw/multi exec smembers get hget hdel hset sadd srem incr hmset hsetnx publish del/) {
		dynsub uc $cmd, sub { $redis->$cmd(@_) };
	}

	for my $cmd (qw/subscribe wait_for_messages/) {
		dynsub uc $cmd, sub { $pubsub->$cmd(@_) };
	}
}

sub cp { defined $contest ? "contest.$contest." : '' }

sub problems			()		{ SMEMBERS cp . 'problem' }
sub contests			()		{ SMEMBERS cp . 'contest' }
sub users				()		{ SMEMBERS cp . 'user' }
sub jobcard				()		{ GET cp . 'job' }

sub job_results			(_)		{ decode_json HGET cp . "job.$_[0]", 'results' }
sub set_job_results		($+)	{ HSET cp . "job.$_[0]", 'results', encode_json $_[1] }
sub job_inmeta			(_)		{ decode_json HGET cp . "job.$_[0]", 'inmeta' }
sub set_job_inmeta		($+)	{ HSET cp . "job.$_[0]", 'inmeta', encode_json $_[1] }
sub problem_meta		(_)		{ decode_json HGET cp . "problem.$_[0]", 'meta' }
sub set_problem_meta	($+)	{ HSET cp . "problem.$_[0]", 'meta', encode_json $_[1] }
sub job_daemon			(_)		{ HGET cp . "job.$_[0]", 'daemon' }
sub set_job_daemon		($$)	{ HSETNX cp . "job.$_[0]", 'daemon', $_[1] };

sub defhash{
	my ($name, @keys) = @_;
	for my $key (@keys) {
		dynsub "${name}_$key", sub (_)  { HGET cp . "$name.$_[0]", $key };
		dynsub "set_${name}_$key", sub ($$) { HSET cp . "$name.$_[0]", $key, $_[1] };
	}

	dynsub "edit_$name", sub {
		my ($key, %values) = @_;
		HMSET cp . "$name.$key", %values;
	};

	dynsub "insert_$name", sub {
		my ($key, %values) = @_;
		SADD cp . $name, $key or return;
		HMSET cp . "$name.$key", %values;
	};
	dynsub "remove_$name", sub (_) {
		my $key = shift;
		SREM cp . $name, $key;
		DEL cp . "$name.$key";
	};

	dynsub "push_$name", sub {
		my $nr = INCR cp . $name;
		HMSET cp . "$name.$nr", @_;
		$nr
	};
}

defhash problem => qw/name level statement owner author/;
defhash contest => qw/start end name owner/;
defhash job => qw/date errors extension filesize private problem result result_text user/;
defhash user => qw/name email town university level/;

sub clean_job (_){
	HDEL cp . "job.$_[0]", qw/result result_text results daemon/
}

sub mark_open {
	my ($problem, $user) = @_;
	HSETNX cp . 'open', "$problem.$user", time;
}

sub get_open {
	my ($problem, $user) = @_;
	HGET cp . 'open', "$problem.$user";
}

our @EXPORT = do {
	no strict 'refs';
	grep { $_ =~ /^[a-zA-Z]/ and exists &$_ } keys %{__PACKAGE__ . '::'};
};

1;
__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Data - Gruntmaster 6000 Online Judge -- database interface and tools

=head1 SYNOPSIS

  for my $problem (problems) {
    say "Problem name: " . problem_name $problem;
    say "Problem level: " . problem_level $problem;
    ...
  }

=head1 DESCRIPTION

Gruntmaster::Data is the Redis interface used by the Gruntmaster 6000 Online Judge. It exports many functions for talking to the database. All functions are exported by default.

The current contest is selected by setting the C<< $Gruntmaster::Data::contest >> variable.

  local $Gruntmaster::Data::contest = 'mycontest';
  say 'There are' . jobcard . ' jobs in my contest';

=head1 FUNCTIONS

=head2 Redis

Gruntmaster::Data exports some functions for talking directly to the Redis server. These functions should not normally be used, except for B<MULTI>, B<EXEC>, B<PUBLISH>, B<SUBSCRIBE> and B<WAIT_FOR_MESSAGES>.

These functions correspond to Redis commands. The current list is: B<< MULTI EXEC SMEMBERS GET HGET HDEL HSET SADD SREM INCR HMSET HSETNX DEL PUBLISH SUBSCRIBE WAIT_FOR_MESSAGES >>.

=head2 Problems

=over

=item B<problems>

Returns a list of problems in the current contest.

=item B<problem_meta> I<$problem>

Returns a problem's meta.

=item B<set_problem_meta> I<$problem>, I<$meta>

Sets a problem's meta.

=item B<problem_name> I<$problem>

Returns a problem's name.

=item B<set_problem_name> I<$problem>, I<$name>

Sets a problem's name.

=item B<problem_level> I<$problem>

Returns a problem's level. The levels are beginner, easy, medium, hard.

=item B<set_problem_level> I<$problem>, I<$level>

Sets a problem's level. The levels are beginner, easy, medium, hard.

=item B<problem_statement> I<$problem>

Returns a problem's statement.

=item B<set_problem_statement> I<$problem>, I<$statement>

Sets a problem's statement.

=item B<problem_owner> I<$problem>

Returns a problem's owner.

=item B<set_problem_owner> I<$problem>, I<$owner>

Sets a problem's owner.

=item B<problem_author> I<$problem>

Returns a problem's author.

=item B<set_problem_author> I<$problem>, I<$author>

Sets a problem's author.

=item B<get_open> I<$problem>, I<$user>

Returns the time when I<$user> opened I<$problem>.

=item B<mark_open> I<$problem>, I<$user>

Sets the time when I<$user> opened I<$problem> to the current time. Does nothing if I<$user> has already opened I<$problem>.

=item B<insert_problem> I<$id>, I<$key> => I<$value>, ...

Inserts a problem with id I<$id> and the given initial configuration. Does nothing if a problem with id I<$id> already exists. Returns true if the problem was added, false otherwise.

=item B<edit_problem> I<$id>, I<$key> => I<$value>, ...

Updates the configuration of a problem. The values of the given keys are updated. All other keys/values are left intact.

=item B<remove_problem> I<$id>

Removes a problem.

=back

=head2 Contests

B<<< WARNING: these functions only work correctly when C<< $Gruntmaster::Data::contest >> is undef >>>

=over

=item B<contests>

Returns a list of contests.

=item B<contest_start> I<$contest>

Returns a contest's start time.

=item B<set_contest_start> I<$contest>, I<$start>

Sets a contest's start time.

=item B<contest_end> I<$contest>

Returns a contest's end time.

=item B<set_contest_end> I<$contest>, I<$end>

Sets a contest's end time.

=item B<contest_name> I<$contest>

Returns a contest's name.

=item B<set_contest_name> I<$contest>, I<$name>

Sets a contest's name.

=item B<contest_owner> I<$contest>

Returns a contest's owner.

=item B<set_contest_owner> I<$contest>, I<$owner>

Sets a contest's owner.

=item B<insert_contest> I<$id>, I<$key> => I<$value>, ...

Inserts a contest with id I<$id> and the given initial configuration. Does nothing if a contest with id I<$id> already exists. Returns true if the contest was added, false otherwise.

=item B<edit_contest> I<$id>, I<$key> => I<$value>, ...

Updates the configuration of a contest. The values of the given keys are updated. All other keys/values are left intact.

=item B<remove_contest> I<$id>

Removes a contest.

=back

=head2 Jobs

=over

=item B<jobcard>

Returns the number of jobs in the database.

=item B<job_results> I<$job>

Returns an array of job results. Each element corresponds to a test and is a hashref with keys B<id> (test number), B<result> (result code, see L<Gruntmaster::Daemon::Constants>), B<result_text> (result description) and B<time> (time taken).

=item B<set_job_results> I<$job>, I<$results>

Sets a job's results.

=item B<job_inmeta> I<$job>

Returns a job's meta.

=item B<set_job_inmeta> I<$job>, I<$meta>

Sets a job's meta.

=item B<job_daemon> I<$job>

Returns the hostname:pid of the daemon which ran this job.

=item B<set_job_daemon> I<$job>, I<$hostname_and_pid>

If the job has no associated daemon, it sets the daemon and returns true. Otherwise it returns false without setting the daemon.

=item B<job_date> I<$job>

Returns a job's submit date.

=item B<set_job_date> I<$job>, I<$date>

Sets a job's submit date.

=item B<job_errors> I<$job>

Returns a job's compile errors.

=item B<set_job_errors> I<$job>, I<$errors>

Sets a job's compile errors.

=item B<job_extension> I<$job>

Returns a job's file name extension (e.g. "cpp", "pl", "java").

=item B<set_job_extension> I<$job>, I<$extension>

Sets a job's file name extension.

=item B<job_filesize> I<$job>

Returns a job's source file size, in bytes.

=item B<set_job_filesize> I<$job>, I<$filesize>

Sets a job's source file size, in bytes.

=item B<job_private> I<$job>

Returns the value of a job's private flag.

=item B<set_job_private> I<$job>, I<$private>

Sets the value of a job's private flag.

=item B<job_problem> I<$job>

Returns a job's problem.

=item B<set_job_problem> I<$job>, I<$problem>

Sets a job's problem.

=item B<job_result> I<$job>

Returns a job's result code. Possible result codes are described in L<Gruntmaster::Daemon::Constants>

=item B<set_job_result> I<$job>, I<$result>

Sets a job's result code.

=item B<job_result_text> I<$job>

Returns a job's result text.

=item B<set_job_result_text> I<$job>, I<$result_text>

Sets a job's result text.

=item B<job_user> I<$job>

Returns the user who submitted a job.

=item B<set_job_user> I<$job>, I<$user>

Sets the suer who submitted a job.

=item B<clean_job> I<$job>

Removes a job's daemon, result code, result text and result array.

=item B<push_job> I<$key> => I<$value>, ...

Inserts a job with a given initial configuration. Returns the id of the newly-added job.

=item B<edit_job> I<$id>, I<$key> => I<$value>, ...

Updates the configuration of a job. The values of the given keys are updated. All other keys/values are left intact.

=item B<remove_job> I<$id>

Removes a job.

=back

=head2 Users

B<<< WARNING: these functions only work correctly when C<< $Gruntmaster::Data::contest >> is undef >>>

=over

=item B<users>

Returns a list of users.

=item B<user_name> I<$user>

Returns a user's full name.

=item B<set_user_name> I<$user>, I<$name>

Sets a user's full name.

=item B<user_email> I<$user>

Returns a user's email address.

=item B<set_user_email> I<$user>, I<$email>

Sets a user's email address.

=item B<user_town> I<$user>

Returns a user's town.

=item B<set_user_town> I<$user>, I<$town>

Sets a user's town.

=item B<user_university> I<$user>

Returns a user's university/highschool/place of work/etc.

=item B<set_user_university> I<$user>, I<$university>

Sets a user's university, highschool/place of work/etc.

=item B<user_level> I<$user>

Returns a user's current level of study. One of 'Highschool', 'Undergraduate', 'Master', 'Doctorate' or 'Other'.

=item B<set_user_level> I<$user>, I<$level>

Sets a user's current level of study.

=item B<insert_user> I<$id>, I<$key> => I<$value>, ...

Inserts a user with id I<$id> and the given initial configuration. Does nothing if a user with id I<$id> already exists. Returns true if the user was added, false otherwise.

=item B<edit_user> I<$id>, I<$key> => I<$value>, ...

Updates the configuration of a user. The values of the given keys are updated. All other keys/values are left intact.

=item B<remove_user> I<$id>

Removes a user.

=back

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


=cut
