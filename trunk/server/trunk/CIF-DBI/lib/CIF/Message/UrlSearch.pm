package CIF::Message::UrlSearch;
use base 'CIF::Message::Url';

use strict;
use warnings;

__PACKAGE__->table('urls_search');
__PACKAGE__->has_a(uuid => 'CIF::Message');

__PACKAGE__->set_sql('feed' => qq{
    SELECT * FROM __TABLE__
    WHERE detecttime >= ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;
