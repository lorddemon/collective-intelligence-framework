package CIF::User;
use base 'CIF::DBI';

__PACKAGE__->table('users');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id email firstname lastname affiliation created/);
__PACKAGE__->sequence('users_id_seq');
