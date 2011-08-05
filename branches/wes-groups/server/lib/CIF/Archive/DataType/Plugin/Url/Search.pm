package CIF::Archive::DataType::Plugin::Url::Search;
use base 'CIF::Archive::DataType::Plugin::Url';

sub prepare {
    my $class = shift;
    my $info = shift;

    return(0) unless($info->{'impact'} =~ /search/);
    return('search');
}

1;
