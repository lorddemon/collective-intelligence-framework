package CIF::Message::DomainWhitelist;
use base 'CIF::Message::Domain';

__PACKAGE__->table('domains_whitelist');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
