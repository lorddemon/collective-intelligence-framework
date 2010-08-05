package CIF::Message::DomainWhitelist;
use base 'CIF::Message::Domain';

use strict;
use warnings;

__PACKAGE__->table('domains_whitelist');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    $info->{'impact'} = 'domain whitelist' unless($info->{'impact'});
    $self->SUPER::insert($info);
}

sub isWhitelisted {
    my $self = shift;
    my $a = shift;
    
    return undef unless($a);

    my $sql = '';

    ## TODO -- do this by my $parts = split(/\./,$a); foreach ....
    for($a){
        if(/([a-zA-Z0-9-]+\.[a-zA-Z]{2,4})$/){
            $sql .= qq{address LIKE '%$1'};
        }
        if(/((?:[a-zA-Z0-9-]+\.){2,2}[a-zA-Z]{2,4})$/){
            $sql .= qq{ OR address LIKE '%$1'};
        }
        if(/((?:[a-zA-Z0-9-]+\.){3,3}[a-zA-Z]{2,4})$/){
            $sql .= qq{ OR address LIKE '%$1'};
        }
        if(/((?:[a-zA-Z0-9-]+\.){4,4}[a-zA-Z]{2,4})$/){
            $sql .= qq{ OR address LIKE '%$1'};
        }

    }
    $sql .= qq{\nORDER BY detecttime DESC, created DESC, id DESC};
    
    return $self->SUPER::retrieve_from_sql($sql);
}
1;
