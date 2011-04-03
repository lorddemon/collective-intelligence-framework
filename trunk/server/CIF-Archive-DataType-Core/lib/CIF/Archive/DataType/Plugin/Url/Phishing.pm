package CIF::Archive::DataType::Plugin::Url::Phishing;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /phish/);
    return('url_phishing');
}

1;

