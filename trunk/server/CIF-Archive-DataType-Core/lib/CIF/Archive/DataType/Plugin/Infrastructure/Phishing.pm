package CIF::Archive::DataType::Plugin::Infrastructure::Phishing;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /phish/);
    return('infrastructure_phishing');
}

1;
