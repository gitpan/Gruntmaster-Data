use utf8;
package Gruntmaster::Data::Result::Job;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Gruntmaster::Data::Result::Job - List of jobs

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<jobs>

=cut

__PACKAGE__->table("jobs");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'jobs_id_seq'

=head2 contest

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 daemon

  data_type: 'text'
  is_nullable: 1

hostname:PID of daemon that last executed this job. NULL if never executed

=head2 date

  data_type: 'bigint'
  is_nullable: 0

Unix time when job was submitted

=head2 errors

  data_type: 'text'
  is_nullable: 1

Compiler errors

=head2 extension

  data_type: 'text'
  is_nullable: 0

File extension of submitted program, without a leading dot

=head2 format

  data_type: 'text'
  is_nullable: 0

Format (programming language) of submitted program

=head2 private

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 problem

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 result

  data_type: 'integer'
  is_nullable: 1

Job result (integer constant from Gruntmaster::Daemon::Constants)

=head2 result_text

  data_type: 'text'
  is_nullable: 1

Job result (human-readable text)

=head2 results

  data_type: 'text'
  is_nullable: 1

Per-test results (JSON array of hashes with keys id (test number, counting from 1), result (integer constant from Gruntmaster::Daemon::Constants), result_text (human-readable text), time (execution time in decimal seconds))

=head2 source

  data_type: 'text'
  is_nullable: 0

=head2 owner

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "jobs_id_seq",
  },
  "contest",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "daemon",
  { data_type => "text", is_nullable => 1 },
  "date",
  { data_type => "bigint", is_nullable => 0 },
  "errors",
  { data_type => "text", is_nullable => 1 },
  "extension",
  { data_type => "text", is_nullable => 0 },
  "format",
  { data_type => "text", is_nullable => 0 },
  "private",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "problem",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "result",
  { data_type => "integer", is_nullable => 1 },
  "result_text",
  { data_type => "text", is_nullable => 1 },
  "results",
  { data_type => "text", is_nullable => 1 },
  "source",
  { data_type => "text", is_nullable => 0 },
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

=head2 contest

Type: belongs_to

Related object: L<Gruntmaster::Data::Result::Contest>

=cut

__PACKAGE__->belongs_to(
  "contest",
  "Gruntmaster::Data::Result::Contest",
  { id => "contest" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
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

=head2 problem

Type: belongs_to

Related object: L<Gruntmaster::Data::Result::Problem>

=cut

__PACKAGE__->belongs_to(
  "problem",
  "Gruntmaster::Data::Result::Problem",
  { id => "problem" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 problem_statuses

Type: has_many

Related object: L<Gruntmaster::Data::Result::ProblemStatus>

=cut

__PACKAGE__->has_many(
  "problem_statuses",
  "Gruntmaster::Data::Result::ProblemStatus",
  { "foreign.job" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-12-19 16:54:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hEAVL5heV13+nalSmgr0WA

use Class::Method::Modifiers qw/after/;

sub rawcontest { shift->get_column('contest') }
sub rawowner { shift->get_column('owner') }
sub rawproblem { shift->get_column('problem') }

sub rerun {
	shift->update({daemon => undef, result => -2, result_text => undef});
}

after qw/insert update delete/ => sub {
	my ($self) = @_;
	Gruntmaster::Data::purge '/us/';
	Gruntmaster::Data::purge '/us/' . $self->rawowner;
	Gruntmaster::Data::purge '/st/' . $self->rawcontest if $self->rawcontest;
	Gruntmaster::Data::purge '/log/';
	Gruntmaster::Data::purge '/log/' . $self->id;
};

1;

__END__

=head1 METHODS

=head2 rerun

Reruns this job.

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
