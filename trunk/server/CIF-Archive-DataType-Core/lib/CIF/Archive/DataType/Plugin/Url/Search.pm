package CIF::Archive::DataType::Plugin::Url::Search;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;

    return(0) unless($info->{'impact'} =~ /search/);
    return('url_search');
}

1;
