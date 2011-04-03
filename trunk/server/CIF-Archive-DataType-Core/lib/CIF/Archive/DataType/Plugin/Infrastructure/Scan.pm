package CIF::Archive::DataType::Plugin::Infrastructure::Scan;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /scan/);
    return('infrastructure_scanning');
}

1;
