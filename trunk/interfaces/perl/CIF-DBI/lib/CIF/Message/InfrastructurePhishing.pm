package CIF::Message::InfrastructurePhishing;
use base 'CIF::Message::Infrastructure';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_phishing');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
