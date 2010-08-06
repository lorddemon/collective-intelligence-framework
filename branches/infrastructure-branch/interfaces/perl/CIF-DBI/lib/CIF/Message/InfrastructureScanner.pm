package CIF::Message::InfrastructureScanner;
use base 'CIF::Message::Infrastructure';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_scanner');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
