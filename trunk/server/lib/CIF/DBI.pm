package CIF::DBI;
use base 'Class::DBI';

use Config::Simple;

__PACKAGE__->connection('DBI:Pg:database=cif','postgres','',{ AutoCommit => 1} );
__PACKAGE__->set_sql('lastval' => qq{ SELECT last_value from archive_id_seq });

# because UUID's are really primary keys too in our schema
# this overrides some of the default functionality of Class::DBI and 'id'
sub retrieve {
    my $class = shift;
    my %keys = @_;

    return $class->SUPER::retrieve(@_) unless($keys{'uuid'});

    require CIF::Archive;
    my @recs = CIF::Archive->search(uuid => $keys{'uuid'});
    return unless(@recs);
    return($recs[0]);
}

1;

=head1 NAME

CIF::DBI - Perl extension for interfacing with the CIF data-warehouse.

=head1 SYNOPSIS

  use CIF::DBI;
  blah blah blah

=head1 DESCRIPTION

=cut

