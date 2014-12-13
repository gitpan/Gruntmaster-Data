use utf8;
package Gruntmaster::Data::Result::Contest;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Gruntmaster::Data::Result::Contest

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<contests>

=cut

__PACKAGE__->table("contests");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 start

  data_type: 'integer'
  is_nullable: 0

=head2 stop

  data_type: 'integer'
  is_nullable: 0

=head2 owner

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "start",
  { data_type => "integer", is_nullable => 0 },
  "stop",
  { data_type => "integer", is_nullable => 0 },
  "owner",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 contest_problems

Type: has_many

Related object: L<Gruntmaster::Data::Result::ContestProblem>

=cut

__PACKAGE__->has_many(
  "contest_problems",
  "Gruntmaster::Data::Result::ContestProblem",
  { "foreign.contest" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 contest_statuses

Type: has_many

Related object: L<Gruntmaster::Data::Result::ContestStatus>

=cut

__PACKAGE__->has_many(
  "contest_statuses",
  "Gruntmaster::Data::Result::ContestStatus",
  { "foreign.contest" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 jobs

Type: has_many

Related object: L<Gruntmaster::Data::Result::Job>

=cut

__PACKAGE__->has_many(
  "jobs",
  "Gruntmaster::Data::Result::Job",
  { "foreign.contest" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 opens

Type: has_many

Related object: L<Gruntmaster::Data::Result::Open>

=cut

__PACKAGE__->has_many(
  "opens",
  "Gruntmaster::Data::Result::Open",
  { "foreign.contest" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owner

Type: belongs_to

Related object: L<Gruntmaster::Data::Result::User>

=cut

__PACKAGE__->belongs_to(
  "owner",
  "Gruntmaster::Data::Result::User",
  { id => "owner" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 problems

Type: many_to_many

Composing rels: L</contest_problems> -> problem

=cut

__PACKAGE__->many_to_many("problems", "contest_problems", "problem");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-12-11 23:51:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nu+Io9AhYkzYCky5UpCaKQ

use List::Util qw/sum/;

sub is_pending {
	my ($self, $time) = @_;
	$self->start > ($time // time)
}

sub is_finished {
	my ($self, $time) = @_;
	$self->stop <= ($time // time)
}

sub is_running {
	my ($self, $time) = @_;
	!$self->is_pending($time) && !$self->is_finished($time)
}

sub calc_score{
	my ($mxscore, $time, $tries, $totaltime) = @_;
	my $score = $mxscore;
	$time = 0 if $time < 0;
	$time = 300 if $time > $totaltime;
	$score = ($totaltime - $time) / $totaltime * $score;
	$score -= $tries / 10 * $mxscore;
	$score = $mxscore * 3 / 10 if $score < $mxscore * 3 / 10;
	int $score + 0.5
}

sub standings {
	my ($self) = @_;
	my $ct = $self->id;

	my @problems = map { $_->rawproblem } $self->contest_problems->search({contest => $ct}, {qw/join problem order_by problem.level/});
	my (%scores, %tries, %opens);
	$opens{$_->rawproblem, $_->rawowner} = $_ for $self->opens->search({contest => $ct});
	for my $job ($self->jobs->search({contest => $ct}, {qw/order_by me.id prefetch/ => [qw/problem/]})) {
		my $open = $opens{$job->rawproblem, $job->rawowner};
		my $time = $job->date - ($open ? $open->time : $self->start);
		next if $time < 0;
		my $value = $job->problem->value;
		my $factor = $job->result ? 0 : 1;
		$factor = $1 / 100 if $job->result_text =~ /^(\d+ )/s;
		$scores{$job->rawowner}{$job->rawproblem} = int ($factor * calc_score ($value, $time, $tries{$job->rawowner}{$job->rawproblem}++, $self->stop - $self->start));
	}

	my %user_to_name = map { $_->id => $_->name } $self->result_source->schema->users->all;

	my @st = sort { $b->{score} <=> $a->{score} or $a->{user} cmp $b->{user} } map { ## no critic (ProhibitReverseSortBlock)
		my $user = $_;
		+{
			user => $user,
			user_name => $user_to_name{$user},
			score => sum (values %{$scores{$user}}),
			scores => [map { $scores{$user}{$_} // '-'} @problems],
		}
	} keys %scores;

	$st[0]->{rank} = 1;
	$st[$_]->{rank} = $st[$_ - 1]->{rank} + ($st[$_]->{score} < $st[$_ - 1]->{score}) for 1 .. $#st;
	@st
}

1;

__END__

=head1 METHODS

=head2 is_pending(I<[$time]>)

Returns true if the contest is pending at time I<$time> (which defaults to C<time>).

=head2 is_finished(I<[$time]>)

Returns true if the contest is finished at time I<$time> (which defaults to C<time>).

=head2 is_running(I<[$time]>)

Returns true if the contest is running at time I<$time> (which defaults to C<time>).

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
