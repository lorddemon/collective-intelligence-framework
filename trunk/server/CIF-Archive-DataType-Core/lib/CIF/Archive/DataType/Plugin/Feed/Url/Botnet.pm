package CIF::Archive::DataType::Plugin::Feed::Url::Botnet;
use base 'CIF::Archive::DataType::Plugin::Feed::Url';

use strict;
use warnings;

__PACKAGE__->table('feed_url_botnet');

sub prepare {
    my $class = shift;
    my $info = shift;

    return(0) unless($class->SUPER::_prepare($info));
    return(0) unless($info->{'impact'} =~ /botnet/);
    return(1);
}

1;

