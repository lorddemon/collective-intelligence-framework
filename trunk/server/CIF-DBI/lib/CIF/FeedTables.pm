package CIF::FeedTables;
use base 'CIF::Archive';

use strict;
use warnings;

__PACKAGE__->set_sql(_feed_tables => 'SELECT relname FROM pg_stat_user_tables WHERE relname LIKE \'feed_%\' ORDER BY relname ASC');
__PACKAGE__->columns(All => qw/relid relname/);
__PACKAGE__->columns(Primary => 'relid');


1;
