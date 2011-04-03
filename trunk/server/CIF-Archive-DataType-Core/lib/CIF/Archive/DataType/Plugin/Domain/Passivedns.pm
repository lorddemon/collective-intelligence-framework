package CIF::Archive::DataType::Plugin::Domain::Passivedns;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /passivedns/);
    return('domain_passivedns');
}

1;
