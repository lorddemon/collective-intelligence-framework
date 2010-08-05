package CIF::Message::PassiveDomain;
use base 'CIF::Message::Domain';

use strict;
use warnings;

__PACKAGE__->table('passive_domains');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    $info->{'impact'} = 'passive dns data' unless($info->{'impact'});
    $self->SUPER::insert($info);
}
1;
