package CIF::Archive::DataType::Plugin::Domain::Fastflux;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /fastflux/);
    return('domain_fastflux');
}

1;
