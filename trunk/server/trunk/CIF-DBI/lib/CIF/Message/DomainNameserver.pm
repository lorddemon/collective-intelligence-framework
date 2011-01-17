package CIF::Message::DomainNameserver;
use base 'CIF::Message::Domain';

use strict;
use warnings;

__PACKAGE__->table('domain_nameserver');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
