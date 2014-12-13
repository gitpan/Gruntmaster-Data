use utf8;
package Gruntmaster::Data::Result::ContestStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Gruntmaster::Data::Result::ContestStatus

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<contest_status>

=cut

__PACKAGE__->table("contest_status");

=head1 ACCESSORS

=head2 contest

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 owner

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 score

  data_type: 'integer'
  is_nullable: 0

=head2 rank

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "contest",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "owner",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "score",
  { data_type => "integer", is_nullable => 0 },
  "rank",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</owner>

=item * L</contest>

=back

=cut

__PACKAGE__->set_primary_key("owner", "contest");

=head1 RELATIONS

=head2 contest

Type: belongs_to

Related object: L<Gruntmaster::Data::Result::Contest>

=cut

__PACKAGE__->belongs_to(
  "contest",
  "Gruntmaster::Data::Result::Contest",
  { id => "contest" },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-12-11 23:51:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vfOfZeATPRODifpgHO4L0A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
