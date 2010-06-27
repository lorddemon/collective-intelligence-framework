package CIF::Message::MaliciousDomain;
use base 'CIF::Message::Domain';

use strict;
use warnings;

__PACKAGE__->table('malicious_domains');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    $info->{'impact'} = 'malicious domain' unless($info->{'impact'});
    $self->SUPER::insert($info);
}
1;
