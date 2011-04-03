package CIF::Archive::DataType::Plugin::Feed::Url::Phishing;
use base 'CIF::Archive::DataType::Plugin::Feed::Url';

use strict;
use warnings;

__PACKAGE__->table('feed_url_phishing');

sub prepare {
    my $class = shift;
    my $info = shift;

    return(0) unless($class->SUPER::_prepare($info));
    return(0) unless($info->{'impact'} =~ /phish/);
    return(1);
}

1;

