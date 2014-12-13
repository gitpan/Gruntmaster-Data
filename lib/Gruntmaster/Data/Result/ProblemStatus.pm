use utf8;
package Gruntmaster::Data::Result::ProblemStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Gruntmaster::Data::Result::ProblemStatus

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<problem_status>

=cut

__PACKAGE__->table("problem_status");

=head1 ACCESSORS

=head2 problem

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 owner

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 job

  data_type: 'integer'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'problem_status_job_seq'

=head2 solved

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "problem",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "owner",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "job",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "problem_status_job_seq",
  },
  "solved",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</owner>

=item * L</problem>

=back

=cut

__PACKAGE__->set_primary_key("owner", "problem");

=head1 RELATIONS

=head2 job

Type: belongs_to

Related object: L<Gruntmaster::Data::Result::Job>

=cut

__PACKAGE__->belongs_to(
  "job",
  "Gruntmaster::Data::Result::Job",
  { id => "job" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-12-11 23:51:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SUAwYQhgBtoCjtFSOMc4FQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
