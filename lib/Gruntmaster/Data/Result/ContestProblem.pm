use utf8;
package Gruntmaster::Data::Result::ContestProblem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Gruntmaster::Data::Result::ContestProblem - Many-to-many bridge between contests and problems

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<contest_problems>

=cut

__PACKAGE__->table("contest_problems");

=head1 ACCESSORS

=head2 contest

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 problem

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "contest",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "problem",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</contest>

=item * L</problem>

=back

=cut

__PACKAGE__->set_primary_key("contest", "problem");

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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dTFBC3ZKB2T9SCiyQxxe2w

use Class::Method::Modifiers qw/after/;

sub rawcontest { shift->get_column('contest') }
sub rawproblem { shift->get_column('problem') }

after qw/insert update delete/ => sub {
	my ($self) = @_;
	Gruntmaster::Data::purge '/pb/';
	Gruntmaster::Data::purge '/pb/' . $self->rawproblem;
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
