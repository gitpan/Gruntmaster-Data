use utf8;
package Gruntmaster::Data::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Gruntmaster::Data::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 passphrase

  data_type: 'text'
  is_nullable: 1

=head2 admin

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 email

  data_type: 'text'
  is_nullable: 1

=head2 phone

  data_type: 'text'
  is_nullable: 1

=head2 town

  data_type: 'text'
  is_nullable: 1

=head2 university

  data_type: 'text'
  is_nullable: 1

=head2 level

  data_type: 'text'
  is_nullable: 1

=head2 lastjob

  data_type: 'bigint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "passphrase",
  { data_type => "text", is_nullable => 1 },
  "admin",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "email",
  { data_type => "text", is_nullable => 1 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "town",
  { data_type => "text", is_nullable => 1 },
  "university",
  { data_type => "text", is_nullable => 1 },
  "level",
  { data_type => "text", is_nullable => 1 },
  "lastjob",
  { data_type => "bigint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 contests

Type: has_many

Related object: L<Gruntmaster::Data::Result::Contest>

=cut

__PACKAGE__->has_many(
  "contests",
  "Gruntmaster::Data::Result::Contest",
  { "foreign.owner" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 jobs

Type: has_many

Related object: L<Gruntmaster::Data::Result::Job>

=cut

__PACKAGE__->has_many(
  "jobs",
  "Gruntmaster::Data::Result::Job",
  { "foreign.owner" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 opens

Type: has_many

Related object: L<Gruntmaster::Data::Result::Open>

=cut

__PACKAGE__->has_many(
  "opens",
  "Gruntmaster::Data::Result::Open",
  { "foreign.owner" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 problems

Type: has_many

Related object: L<Gruntmaster::Data::Result::Problem>

=cut

__PACKAGE__->has_many(
  "problems",
  "Gruntmaster::Data::Result::Problem",
  { "foreign.owner" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-16 15:23:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Cho4zmn58Mytf2jHvgP+4g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

__END__

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
