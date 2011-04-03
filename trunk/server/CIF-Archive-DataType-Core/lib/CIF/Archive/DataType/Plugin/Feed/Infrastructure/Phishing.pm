package CIF::Archive::DataType::Plugin::Feed::Infrastructure::Phishing;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;

    return(undef) unless($info->{'impact'} =~ /phish/);
    return(1);
}

1;
