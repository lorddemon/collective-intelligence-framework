package CIF::Message::InetWhitelist;
use base 'CIF::Message::Inet';

use strict;
use warnings;

__PACKAGE__->table('inet_whitelist');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    $info->{'impact'} = 'inet whitelist' unless($info->{'impact'});
    $self->SUPER::insert($info);
}

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
