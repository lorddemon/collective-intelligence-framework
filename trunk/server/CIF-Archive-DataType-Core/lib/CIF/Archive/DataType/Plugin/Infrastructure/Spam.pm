package CIF::Archive::DataType::Plugin::Infrastructure::Spam;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /spam/);
    return('infrastructure_spam');
}

1;
