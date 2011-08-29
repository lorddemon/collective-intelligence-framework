package CIF::Archive::DataType::Plugin::Domain::Search;
use base 'CIF::Archive::DataType::Plugin::Domain';

__PACKAGE__->table('domain_search');

sub prepare {
    my $class = shift;
    my $info = shift;
    return unless($info->{'impact'});
    return(0) unless($info->{'impact'} =~ /search/);
    return('search');
}

1;
