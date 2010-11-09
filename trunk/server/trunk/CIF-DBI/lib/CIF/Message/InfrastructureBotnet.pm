package CIF::Message::InfrastructureBotnet;
use base 'CIF::Message::Infrastructure';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_botnet');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
