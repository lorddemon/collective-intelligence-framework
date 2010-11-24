package CIF::Message::DomainSearch;
use base 'CIF::Message::Domain';

use strict;
use warnings;

__PACKAGE__->table('domains_search');
__PACKAGE__->has_a(uuid => 'CIF::Message');

__PACKAGE__->set_sql('feed' => qq{
    SELECT *
    FROM __TABLE__
    WHERE detecttime >= ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;
