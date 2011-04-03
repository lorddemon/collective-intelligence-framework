package CIF::Archive::DataType::Plugin::Infrastructure::Suspicious;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /suspicious/);
    return('infrastucture_suspicious');
}

1;
