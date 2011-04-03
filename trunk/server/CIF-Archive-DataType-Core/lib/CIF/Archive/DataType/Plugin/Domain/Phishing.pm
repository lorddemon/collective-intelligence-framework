package CIF::Archive::DataType::Plugin::Domain::Phishing;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /phish/);
    return('domain_phishing');
}

1;
