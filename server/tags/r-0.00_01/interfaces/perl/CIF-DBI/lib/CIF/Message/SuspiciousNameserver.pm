package CIF::Message::SuspiciousNameserver;
use base 'CIF::Message::Domain';

use strict;
use warnings;

__PACKAGE__->table('suspicious_nameservers');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    $info->{'impact'} = 'suspicious nameserver' unless($info->{'impact'});
    $self->SUPER::insert($info);
}
1;
