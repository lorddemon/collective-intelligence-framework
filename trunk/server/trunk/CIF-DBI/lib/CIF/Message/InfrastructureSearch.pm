package CIF::Message::InfrastructureSearch;
use base 'CIF::Message::Infrastructure';

__PACKAGE__->table('infrastructure_search');
__PACKAGE__->has_a(uuid => 'CIF::Message');

1;
