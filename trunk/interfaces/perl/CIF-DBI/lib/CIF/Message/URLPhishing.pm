package CIF::Message::URLPhishing;
use base 'CIF::Message::URL';

use strict;
use warnings;

__PACKAGE__->table('urls_phishing');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
