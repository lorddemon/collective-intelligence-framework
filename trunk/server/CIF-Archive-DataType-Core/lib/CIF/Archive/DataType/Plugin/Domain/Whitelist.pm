package CIF::Archive::DataType::Plugin::Domain::Whitelist;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /whitelist/);
    return('domain_whitelist');
}

1;
