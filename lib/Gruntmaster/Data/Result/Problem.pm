use utf8;
package Gruntmaster::Data::Result::Problem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Gruntmaster::Data::Result::Problem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<problems>

=cut

__PACKAGE__->table("problems");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 author

  data_type: 'text'
  is_nullable: 1

=head2 writer

  data_type: 'text'
  is_nullable: 1

=head2 generator

  data_type: 'text'
  is_nullable: 0

=head2 judge

  data_type: 'text'
  is_nullable: 0

=head2 level

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 olimit

  data_type: 'integer'
  is_nullable: 1

=head2 owner

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 private

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 runner

  data_type: 'text'
  is_nullable: 0

=head2 statement

  data_type: 'text'
  is_nullable: 0

=head2 testcnt

  data_type: 'integer'
  is_nullable: 0

=head2 tests

  data_type: 'text'
  is_nullable: 1

=head2 timeout

  data_type: 'real'
  is_nullable: 0

=head2 value

  data_type: 'integer'
  is_nullable: 1

=head2 genformat

  data_type: 'text'
  is_nullable: 1

=head2 gensource

  data_type: 'text'
  is_nullable: 1

=head2 verformat

  data_type: 'text'
  is_nullable: 1

=head2 versource

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "author",
  { data_type => "text", is_nullable => 1 },
  "writer",
  { data_type => "text", is_nullable => 1 },
  "generator",
  { data_type => "text", is_nullable => 0 },
  "judge",
  { data_type => "text", is_nullable => 0 },
  "level",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "olimit",
  { data_type => "integer", is_nullable => 1 },
  "owner",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "private",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "runner",
  { data_type => "text", is_nullable => 0 },
  "statement",
  { data_type => "text", is_nullable => 0 },
  "testcnt",
  { data_type => "integer", is_nullable => 0 },
  "tests",
  { data_type => "text", is_nullable => 1 },
  "timeout",
  { data_type => "real", is_nullable => 0 },
  "value",
  { data_type => "integer", is_nullable => 1 },
  "genformat",
  { data_type => "text", is_nullable => 1 },
  "gensource",
  { data_type => "text", is_nullable => 1 },
  "verformat",
  { data_type => "text", is_nullable => 1 },
  "versource",
  { data_type => "text", is_nullable => 1 },
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
  { "foreign.problem" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 jobs

Type: has_many

Related object: L<Gruntmaster::Data::Result::Job>

=cut

__PACKAGE__->has_many(
  "jobs",
  "Gruntmaster::Data::Result::Job",
  { "foreign.problem" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 opens

Type: has_many

Related object: L<Gruntmaster::Data::Result::Open>

=cut

__PACKAGE__->has_many(
  "opens",
  "Gruntmaster::Data::Result::Open",
  { "foreign.problem" => "self.id" },
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

=head2 contests

Type: many_to_many

Composing rels: L</contest_problems> -> contest

=cut

__PACKAGE__->many_to_many("contests", "contest_problems", "contest");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-16 15:03:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tvap77v0faSMxFiLu1uggQ

sub is_private {
	my ($self, $time) = @_;
	return 1 if $self->private;
	grep { $_->contest->is_pending($time) } $self->contest_problems;
}

sub is_in_archive {
	my ($self, $time) = @_;
	0 == grep { $_->contest->is_running($time) } $self->contest_problems;
}

sub rerun {
	$_->rerun for shift->jobs
}

1;

__END__

=head1 METHODS

=head2 is_private(I<[$time]>)

Returns true if the problem is private at time I<$time> (which defaults to C<time>).

=head2 is_in_archive(I<[$time]>)

Returns true if the problem is in the archive at time I<$time> (which defaults to C<time>).

=head2 rerun

Reruns all jobs for this problem.

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.1 or,
at your option, any later version of Perl 5 you may have available.


=cut