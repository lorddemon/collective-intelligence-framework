package CIF::Archive::DataType::Plugin::Infrastructure::Search;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

__PACKAGE__->table('infrastructure_search');

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /search/);
    return('search');
}

1;
