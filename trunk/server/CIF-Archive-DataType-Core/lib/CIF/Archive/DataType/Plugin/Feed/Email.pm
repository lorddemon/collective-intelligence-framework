package CIF::Archive::DataType::Plugin::Feed::Email;

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => ['CIF::Archive::DataType::Plugin::Feed::Email'];

sub prepare {
    my $class = shift;
    my $info = shift;

    return(0) unless($info->{'impact'} =~ /email/);
    return('feed_email');
}

1;
