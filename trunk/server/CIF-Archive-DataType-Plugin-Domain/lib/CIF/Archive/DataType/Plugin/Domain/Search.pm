package CIF::Archive::DataType::Plugin::Domain::Search;
use base 'CIF::Archive::DataType::Plugin::Domain';

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /search/);
    return('domain_search');
}

1;
