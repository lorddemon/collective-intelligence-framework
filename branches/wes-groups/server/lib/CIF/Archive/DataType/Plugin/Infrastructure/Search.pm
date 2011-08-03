package CIF::Archive::DataType::Plugin::Infrastructure::Search;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /search/);
    return('infrastructure_search');
}

1;
