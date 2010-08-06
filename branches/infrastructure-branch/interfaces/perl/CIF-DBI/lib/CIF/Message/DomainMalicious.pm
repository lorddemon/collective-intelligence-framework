package CIF::Message::DomainMalicious;
use base 'CIF::Message::Domain';

use strict;
use warnings;

__PACKAGE__->table('domains_malicious');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
