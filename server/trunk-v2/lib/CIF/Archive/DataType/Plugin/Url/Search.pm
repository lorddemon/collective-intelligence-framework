package CIF::Archive::DataType::Plugin::Url::Search;
use base 'CIF::Archive::DataType::Plugin::Url';

__PACKAGE__->table('url_search');

sub prepare {
    my $class = shift;
    my $info = shift;

    return(0) unless($info->{'impact'} =~ /search/);
    return('search');
}

1;
