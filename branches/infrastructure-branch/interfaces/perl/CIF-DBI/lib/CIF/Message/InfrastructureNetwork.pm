package CIF::Message::InfrastructureNetwork;
use base 'CIF::Message::Infrastructure';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_network');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
