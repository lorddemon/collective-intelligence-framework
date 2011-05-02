package CIF::DBI;
use base 'Class::DBI';

use Config::Simple;

__PACKAGE__->connection('DBI:Pg:database=cif;host=localhost','postgres','',{ AutoCommit => 1} );

1;

=head1 NAME

CIF::DBI - Perl extension for interfacing with the CIF data-warehouse.

=head1 SYNOPSIS

  use CIF::DBI;
  blah blah blah

=head1 DESCRIPTION

=cut

