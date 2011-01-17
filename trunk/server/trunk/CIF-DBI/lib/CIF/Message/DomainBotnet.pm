package CIF::Message::DomainBotnet;
use base 'CIF::Message::Domain';

use strict;
use warnings;

__PACKAGE__->table('domain_botnet');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
