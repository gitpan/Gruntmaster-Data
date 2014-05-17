use utf8;
package Gruntmaster::Data;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-03-05 13:11:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dAEmtAexvUaNXLgYz2rNEg

our $VERSION = '5999.000_005';

use Lingua::EN::Inflect qw/PL_N/;
use Sub::Name qw/subname/;

sub dynsub{
	our ($name, $sub) = @_;
	no strict 'refs';
	*$name = subname $name => $sub
}

BEGIN {
	for my $rs (qw/contest contest_problem job open problem user/) {
		my $rsname = ucfirst $rs;
		$rsname =~ s/_([a-z])/\u$1/g;
		dynsub PL_N($rs) => sub { $_[0]->resultset($rsname)              };
		dynsub      $rs  => sub { $_[0]->resultset($rsname)->find($_[1]) };
	}
}

1;

__END__

=encoding utf-8

=head1 NAME

Gruntmaster::Data - Gruntmaster 6000 Online Judge -- database interface and tools

=head1 SYNOPSIS

  my $db = Gruntmaster::Data->connect('dbi:Pg:');

  my $problem = $db->problem('my_problem');
  $problem->update({timeout => 2.5}); # Set time limit to 2.5 seconds
  $problem->rerun; # And rerun all jobs for this problem

  # ...

  my $contest = $db->contests->create({ # Create a new contest
    id => 'my_contest',
    name => 'My Awesome Contest',
    start => time + 100,
    end => time + 1900,
  });
  $db->contest_problems->create({ # Add a problem to the contest
    contest => 'my_contest',
    problem => 'my_problem',
  });

  say 'The contest has not started yet' if $contest->is_pending;

  # ...

  my @jobs = $db->jobs->search({contest => 'my_contest', owner => 'MGV'})->all;
  $_->rerun for @jobs; # Rerun all jobs sent by MGV in my_contest

=head1 DESCRIPTION

Gruntmaster::Data is the interface to the Gruntmaster 6000 database. Read the L<DBIx::Class> documentation for usage information.

In addition to the typical DBIx::Class::Schema methods, this module contains several convenience methods:

=over

=item contests

Equivalent to C<< $schema->resultset('Contest') >>

=item contest_problems

Equivalent to C<< $schema->resultset('ContestProblem') >>

=item jobs

Equivalent to C<< $schema->resultset('Job') >>

=item problems

Equivalent to C<< $schema->resultset('Problem') >>

=item users

Equivalent to C<< $schema->resultset('User') >>

=item contest($id)

Equivalent to C<< $schema->resultset('Contest')->find($id) >>

=item job($id)

Equivalent to C<< $schema->resultset('Job')->find($id) >>

=item problem($id)

Equivalent to C<< $schema->resultset('Problem')->find($id) >>

=item user($id)

Equivalent to C<< $schema->resultset('User')->find($id) >>

=back

=head1 AUTHOR

Marius Gavrilescu E<lt>marius@ieval.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Marius Gavrilescu

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
