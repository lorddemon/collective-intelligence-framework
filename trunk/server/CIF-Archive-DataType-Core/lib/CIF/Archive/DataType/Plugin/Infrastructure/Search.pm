package CIF::Archive::DataType::Plugin::Infrastructure::Search;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /search/);
    return('infrastructure_search');
}

1;
