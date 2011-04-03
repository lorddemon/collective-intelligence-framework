package CIF::Archive::DataType::Plugin::Domain::Nameserver;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /nameserver/);
    return('domain_nameserver');
}

1;
