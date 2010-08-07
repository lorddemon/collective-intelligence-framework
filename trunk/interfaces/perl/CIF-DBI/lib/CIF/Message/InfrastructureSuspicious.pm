package CIF::Message::InfrastructureSuspicious;
use base 'CIF::Message::Infrastructure';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_suspicious');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
