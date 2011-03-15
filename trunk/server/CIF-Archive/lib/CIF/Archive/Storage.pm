package CIF::Archive::Storage;

use strict;
use warnings;

use Module::Pluggable require => 1;

sub format {
    my $class = shift;
    my @bits = split(/\:\:/,$class);
    return(lc($bits[$#bits]));
}

sub prepare { return(0) };

sub to { return; }

sub from { return; }

1;
