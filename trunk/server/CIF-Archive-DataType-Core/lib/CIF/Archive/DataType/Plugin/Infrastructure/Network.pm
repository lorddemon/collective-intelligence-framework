package CIF::Archive::DataType::Plugin::Infrastructure::Network;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /network/);
    return('infrastructure_network');
}

1;
