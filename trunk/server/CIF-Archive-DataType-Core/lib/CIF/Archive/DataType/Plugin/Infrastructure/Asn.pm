package CIF::Archive::DataType::Plugin::Infrastructure::Asn;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /asn/);
    return('infrastructure_asn');
}

1;
