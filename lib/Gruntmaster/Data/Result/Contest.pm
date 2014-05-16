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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-16 15:03:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8PPzBpDmSTq4ukKuxIlLlQ

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
