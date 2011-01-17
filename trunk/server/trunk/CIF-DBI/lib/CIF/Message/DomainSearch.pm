package CIF::Message::DomainSearch;
use base 'CIF::Message::Domain';

__PACKAGE__->table('domain_search');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
