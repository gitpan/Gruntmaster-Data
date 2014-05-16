use utf8;
package Gruntmaster::Data::Result::Job;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Gruntmaster::Data::Result::Job

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

=head2 date

  data_type: 'bigint'
  is_nullable: 0

=head2 errors

  data_type: 'text'
  is_nullable: 1

=head2 extension

  data_type: 'text'
  is_nullable: 0

=head2 format

  data_type: 'text'
  is_nullable: 0

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

=head2 result_text

  data_type: 'text'
  is_nullable: 1

=head2 results

  data_type: 'text'
  is_nullable: 1

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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-16 15:03:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:k3Oq7pNqFoCI5NwY5GaWfQ

sub rerun {
	shift->update({daemon => undef, result => -2, result_text => undef});
}

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
