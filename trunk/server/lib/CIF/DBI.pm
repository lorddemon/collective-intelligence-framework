package CIF::DBI;
use base 'Class::DBI';

use strict;
use warnings;

use Config::Simple;

__PACKAGE__->connection('DBI:Pg:database=cif','postgres','',{ AutoCommit => 1} );
__PACKAGE__->set_sql('lastval' => qq{ SELECT last_value from archive_id_seq });

# because UUID's are really primary keys too in our schema
# this overrides some of the default functionality of Class::DBI and 'id'
sub retrieve {
    my $class = shift;

    return $class->SUPER::retrieve(@_) if(@_ == 1);
    my %keys = @_;

    my @recs = $class->search_retrieve_uuid($keys{'uuid'});
    return unless(defined($#recs) && $#recs > -1);
    return($recs[0]);
}

__PACKAGE__->set_sql('retrieve_uuid' => qq{
    SELECT id,uuid
    FROM __TABLE__
    WHERE uuid = ?
    LIMIT 1
});

1;

=head1 NAME

CIF::DBI - Perl extension for interfacing with the CIF data-warehouse.

=head1 SYNOPSIS

  use CIF::DBI;
  blah blah blah

=head1 DESCRIPTION

=cut

