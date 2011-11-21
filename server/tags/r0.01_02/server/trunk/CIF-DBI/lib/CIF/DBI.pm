package CIF::DBI;
use base Class::DBI;

use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

__PACKAGE__->connection('DBI:Pg:database=cif;host=localhost','postgres','',{ AutoCommit => 1} );

sub check_params {
    my ($self,$tests,$info) = @_;
    
    foreach my $key (keys %$info){
        if(exists($tests->{$key})){
            my $test = $tests->{$key};
            unless($info->{$key} =~ m/$test/){
                return(undef,'invaild value for '.$key.': '.$info->{$key});
            }
        }
    }
    return(1);
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT * FROM __TABLE__
    WHERE detecttime >= ?
    AND severity >= ?
    AND restriction <= ?
    AND NOT (lower(impact) LIKE 'search %' OR lower(impact) LIKE '% whitelist %')
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::DBI - Perl extension for interfacing with the CIF data-warehouse.

=head1 SYNOPSIS

  use CIF::DBI;
  blah blah blah

=head1 DESCRIPTION

=cut

