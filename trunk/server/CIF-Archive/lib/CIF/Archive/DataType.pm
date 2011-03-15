package CIF::Archive::DataType;
use base 'CIF::DBI';

use strict;
use warnings;

use Module::Pluggable require => 1;

sub prepare { return(0) };

1;
