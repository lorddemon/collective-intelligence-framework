package CIF::Message::UrlPhishing;
use base 'CIF::Message::Url';

use strict;
use warnings;

__PACKAGE__->table('url_phishing');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
