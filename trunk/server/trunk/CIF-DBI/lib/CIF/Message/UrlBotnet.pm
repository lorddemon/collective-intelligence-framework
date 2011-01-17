package CIF::Message::UrlBotnet;
use base 'CIF::Message::Url';

use strict;
use warnings;

__PACKAGE__->table('url_botnet');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
