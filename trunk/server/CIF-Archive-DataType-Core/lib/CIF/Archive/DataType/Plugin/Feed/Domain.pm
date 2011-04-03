package CIF::Archive::DataType::Plugin::Feed::Domain;

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => ['CIF::Archive::DataType::Plugin::Feed::Domain'];

sub prepare {
    my $class = shift;
    my $info = shift;

    return(0) unless($info->{'impact'} =~ /domain/);
    return('feed_domain');
}

1;
