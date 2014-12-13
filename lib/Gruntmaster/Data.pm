use utf8;
package Gruntmaster::Data;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-03-05 13:11:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dAEmtAexvUaNXLgYz2rNEg

our $VERSION = '5999.000_012';

use Lingua::EN::Inflect qw/PL_N/;
use JSON::MaybeXS qw/decode_json/;
use PerlX::Maybe qw/maybe/;
use Sub::Name qw/subname/;

use constant PROBLEM_PUBLIC_COLUMNS => [qw/id author writer level name owner private statement timeout olimit value/];
use constant USER_PUBLIC_COLUMNS => [qw/id admin name town university level/];
use constant JOBS_PER_PAGE => 10;

sub dynsub{
	our ($name, $sub) = @_;
	no strict 'refs'; ## no critic (Strict)
	*$name = subname $name => $sub
}

BEGIN {
	for my $rs (qw/contest contest_problem job open problem user problem_status contest_status/) {
		my $rsname = ucfirst $rs;
		$rsname =~ s/_([a-z])/\u$1/gs;
		dynsub PL_N($rs) => sub { $_[0]->resultset($rsname)              };
		dynsub      $rs  => sub { $_[0]->resultset($rsname)->find($_[1]) };
	}
}

sub user_list {
	my $rs = $_[0]->users->search(undef, {columns => USER_PUBLIC_COLUMNS, prefetch => [qw/problem_statuses contest_statuses/]} );
	[ sort { $b->{solved} <=> $a->{solved} or $b->{attempted} <=> $a->{attempted} } map { ## no critic (ProhibitReverseSort)
		my $solved    = $_->problem_statuses->count(solved => 1);
		my $attempted = $_->problem_statuses->count(solved => 0);
		my $contests  = $_->contest_statuses->count;
		+{ $_->get_columns, solved => $solved, attempted => $attempted, contests => $contests }
	} $rs->all ]
}

sub user_entry {
	my ($self, $id) = @_;
	my $user = $self->users->find($id, {columns => USER_PUBLIC_COLUMNS, prefetch => [qw/problem_statuses contest_statuses/]});
	my @problems = map { {problem => $_->get_column('problem'), solved => $_->solved} } $user->problem_statuses;
	my @contests = map { {contest => $_->contest->id, contest_name => $_->contest->name, rank => $_->rank, score => $_->score} } $user->contest_statuses->search(undef, {prefetch => 'contest'});
	+{ $user->get_columns, problems => \@problems, contests => \@contests }
}

sub problem_list {
	my ($self, %args) = @_;
	my $rs = $self->problems->search(undef, {order_by => 'me.name', columns => PROBLEM_PUBLIC_COLUMNS, prefetch => 'owner'});
	$rs = $rs->search({-or => ['contest_problems.contest' => undef, 'contest.stop' => {'<=', time}], 'me.private' => 0}, {join => {'contest_problems' => 'contest'}, distinct => 1}) unless $args{contest};
	$rs = $rs->search({'contest_problems.contest' => $args{contest}}, {join => 'contest_problems'}) if $args{contest};
	$rs = $rs->search({'me.owner' => $args{owner}}) if $args{owner};
	my %params;
	$params{contest} = $args{contest} if $args{contest};
	for ($rs->all) {
		$params{$_->level} //= [];
		push @{$params{$_->level}}, {$_->get_columns, owner_name => $_->owner->name} ;
	}
	\%params
}

sub problem_entry {
	my ($self, $id, $contest, $user) = @_;
	my $running = $contest && $self->contest($contest)->is_running;
	my $columns = PROBLEM_PUBLIC_COLUMNS;
	push @$columns, 'solution' unless $running;
	my $pb = $self->problems->find($id, {columns => $columns, prefetch => 'owner'});
	eval { ## no critic (RequireCheckingReturnValueOfEval)
		$self->opens->create({
			contest => $contest,
			problem => $id,
			owner => $user,
			time => time,
		})
	} if $running;
	$contest &&= $self->contest($contest);
	+{ $pb->get_columns, owner_name => $pb->owner->name, cansubmit => $contest ? $running : 1, $running ? (contest_start => $contest->start, contest_stop => $contest->stop) : () }
}

sub contest_list {
	my ($self, %args) = @_;
	my $rs = $self->contests->search(undef, {order_by => {-desc => 'start'}, prefetch => 'owner'});
	$rs = $rs->search({owner => $args{owner}}) if $args{owner};
	my %params;
	for ($rs->all) {
		my $state = $_->is_pending ? 'pending' : $_->is_running ? 'running' : 'finished';
		$params{$state} //= [];
		push @{$params{$state}}, { $_->get_columns, started => !$_->is_pending, owner_name => $_->owner->name };
	}
	\%params
}

sub contest_entry {
	my ($self, $id) = @_;
	my $ct = $self->contest($id);
	+{ $ct->get_columns, started => !$ct->is_pending, owner_name => $ct->owner->name }
}

sub job_list {
	my ($self, %args) = @_;
	$args{page} //= 1;
	my $rs = $self->jobs->search(undef, {order_by => {-desc => 'me.id'}, prefetch => ['problem', 'owner'], rows => JOBS_PER_PAGE, page => $args{page}});
	$rs = $rs->search({'me.owner' => $args{owner}})   if $args{owner};
	$rs = $rs->search({contest    => $args{contest}}) if $args{contest};
	$rs = $rs->search({problem    => $args{problem}}) if $args{problem};
	return {
		log => [map {
			my %params = $_->get_columns;
			$params{owner_name}   = $_->owner->name;
			$params{problem_name} = $_->problem->name;
			$params{results} &&= decode_json $params{results};
			$params{size}      = length $params{source};
			delete $params{source};
			\%params
		} $rs->all],
		current_page => $rs->pager->current_page,
		maybe previous_page => $rs->pager->previous_page,
		maybe next_page => $rs->pager->next_page,
		maybe last_page => $rs->pager->last_page,
	}
}

sub job_entry {
	my ($self, $id) = @_;
	my $job = $self->jobs->find($id, {prefetch => ['problem', 'owner']});
	my %params = $job->get_columns;
	$params{owner_name}   = $job->owner->name;
	$params{problem_name} = $job->problem->name;
	$params{results} &&= decode_json $params{results};
	$params{size}      = length $params{source};
	delete $params{source};
	\%params
}

sub update_status {
	my ($self) = @_;
	my @jobs = $self->jobs->search(undef, {cache => 1})->all;

	my %hash;
	$hash{$_->get_column('problem'), $_->get_column('owner')} = [$_->id, $_->result ? 0 : 1] for @jobs;
	my @problem_statuses = map { [split ($;), @{$hash{$_}} ] } keys %hash;

	my @contest_statuses = map {
		my $contest = $_->id;
		map { [$contest, $_->{user}, $_->{score}, $_->{rank}] } $_->standings
	} $self->contests->all;

	my $txn = sub {
		$self->problem_statuses->delete;
		$self->problem_statuses->populate([[qw/problem owner job solved/], @problem_statuses]);
		$self->contest_statuses->delete;
		$self->contest_statuses->populate([[qw/contest owner score rank/], @contest_statuses]);
	};

	$self->txn_do($txn);
}

1;

__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Data - Gruntmaster 6000 Online Judge -- database interface and tools

=head1 SYNOPSIS

  my $db = Gruntmaster::Data->connect('dbi:Pg:');

  my $problem = $db->problem('my_problem');
  $problem->update({timeout => 2.5}); # Set time limit to 2.5 seconds
  $problem->rerun; # And rerun all jobs for this problem

  # ...

  my $contest = $db->contests->create({ # Create a new contest
    id => 'my_contest',
    name => 'My Awesome Contest',
    start => time + 100,
    end => time + 1900,
  });
  $db->contest_problems->create({ # Add a problem to the contest
    contest => 'my_contest',
    problem => 'my_problem',
  });

  say 'The contest has not started yet' if $contest->is_pending;

  # ...

  my @jobs = $db->jobs->search({contest => 'my_contest', owner => 'MGV'})->all;
  $_->rerun for @jobs; # Rerun all jobs sent by MGV in my_contest

=head1 DESCRIPTION

Gruntmaster::Data is the interface to the Gruntmaster 6000 database. Read the L<DBIx::Class> documentation for usage information.

In addition to the typical DBIx::Class::Schema methods, this module contains several convenience methods:

=over

=item contests

Equivalent to C<< $schema->resultset('Contest') >>

=item contest_problems

Equivalent to C<< $schema->resultset('ContestProblem') >>

=item jobs

Equivalent to C<< $schema->resultset('Job') >>

=item problems

Equivalent to C<< $schema->resultset('Problem') >>

=item users

Equivalent to C<< $schema->resultset('User') >>

=item contest($id)

Equivalent to C<< $schema->resultset('Contest')->find($id) >>

=item job($id)

Equivalent to C<< $schema->resultset('Job')->find($id) >>

=item problem($id)

Equivalent to C<< $schema->resultset('Problem')->find($id) >>

=item user($id)

Equivalent to C<< $schema->resultset('User')->find($id) >>

=item user_list

Returns a list of users as an arrayref containing hashrefs.

=item user_entry($id)

Returns a hashref with information about the user $id.

=item problem_list([%args])

Returns a list of problems grouped by level. A hashref with levels as keys.

Takes the following arguments:

=over

=item owner

Only show problems owned by this user

=item contest

Only show problems in this contest

=back

=item problem_entry($id, [$contest, $user])

Returns a hashref with information about the problem $id. If $contest and $user are present, problem open data is updated.

=item contest_list([%args])

Returns a list of contests grouped by state. A hashref with the following keys:

=over

=item pending

An arrayref of hashrefs representing pending contests

=item running

An arrayref of hashrefs representing running contests

=item finished

An arrayref of hashrefs representing finished contests

=back

Takes the following arguments:

=over

=item owner

Only show contests owned by this user.

=back

=item contest_entry($id)

Returns a hashref with information about the contest $id.

=item job_list([%args])

Returns a list of jobs as an arrayref containing hashrefs. Takes the following arguments:

=over

=item owner

Only show jobs submitted by this user.

=item contest

Only show jobs submitted in this contest.

=item problem

Only show jobs submitted for this problem.

=item page

Show this page of results. Defaults to 1. Pages have 10 entries, and the first page has the most recent jobs.

=back

=item job_entry($id)

Returns a hashref with information about the job $id.

=back

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
