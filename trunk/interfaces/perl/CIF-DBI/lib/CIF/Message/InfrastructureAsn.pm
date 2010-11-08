package CIF::Message::InfrastructureAsn;
use base 'CIF::Message::Infrastructure';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_asn');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
