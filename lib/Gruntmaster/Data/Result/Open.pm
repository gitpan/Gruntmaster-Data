use utf8;
package Gruntmaster::Data::Result::Open;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Gruntmaster::Data::Result::Open

=head1 DESCRIPTION

List of (contest, problem, user, time when user opened problem)

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<opens>

=cut

__PACKAGE__->table("opens");

=head1 ACCESSORS

=head2 contest

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 problem

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 owner

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 time

  data_type: 'bigint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "contest",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "problem",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "owner",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "time",
  { data_type => "bigint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</contest>

=item * L</problem>

=item * L</owner>

=back

=cut

__PACKAGE__->set_primary_key("contest", "problem", "owner");

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-12-19 16:44:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jAao0vjOW87mO37ZQhm4Cw

use Class::Method::Modifiers qw/after/;

sub rawcontest { shift->get_column('contest') }
sub rawowner { shift->get_column('owner') }
sub rawproblem { shift->get_column('problem') }

after qw/insert update delete/ => sub {
	my ($self) = @_;
	Gruntmaster::Data::purge '/st/' . $self->rawcontest;
};

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
