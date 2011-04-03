package CIF::Archive::DataType::Plugin::Feed::Infrastructure;

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => ['CIF::Archive::DataType::Plugin::Feed::Infrastructure'];

sub prepare {
    my $class = shift;
    my $info = shift;

    return(0) unless($info->{'impact'} =~ /infrastructure/);
    return('feed_infrastructure');
}

1;
