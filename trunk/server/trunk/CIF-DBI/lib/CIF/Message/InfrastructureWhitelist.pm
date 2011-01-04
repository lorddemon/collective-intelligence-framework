package CIF::Message::InfrastructureWhitelist;
use base 'CIF::Message::Infrastructure';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_whitelist');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
