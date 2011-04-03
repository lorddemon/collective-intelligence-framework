package CIF::Archive::DataType::Plugin::Feed::Infrastructure::Network;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;

    return(undef) unless($info->{'impact'} =~ /network/);
    return(1);
}

1;
