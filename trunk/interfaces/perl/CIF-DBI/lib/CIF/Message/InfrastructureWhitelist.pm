package CIF::Message::InfrastructureWhitelist;
use base 'CIF::Message::Infrastructure';

use strict;
use warnings;

__PACKAGE__->table('infrastructure_whitelist');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub isWhitelisted {
    my $self = shift;
    my $a = shift;
    
    return undef unless($a);

    my $sql = qq{
        $a <<= address 
        ORDER BY detecttime DESC, created DESC, id DESC
    };

    my @ret = $self->SUPER::retrieve_from_sql($sql);

    return @ret;
}
1;
