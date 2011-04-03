package CIF::Archive::DataType::Plugin::Feed::Infrastructure::Botnet;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;

    return(undef) unless($info->{'impact'} =~ /botnet/);
    return(1);
}

1;
