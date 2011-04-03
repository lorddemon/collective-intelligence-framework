package CIF::Archive::DataType::Plugin::Feed::Url;
use base 'CIF::Archive::DataType::Plugin::Feed';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => ['CIF::Archive::DataType::Plugin::Feed::Url'];

sub prepare {
    my $class = shift;
    my $info = shift;

    return(undef) unless($info->{'impact'} =~ /url/);
    return(1);
}

1;
