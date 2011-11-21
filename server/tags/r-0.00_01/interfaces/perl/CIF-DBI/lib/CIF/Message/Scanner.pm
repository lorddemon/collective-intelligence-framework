package CIF::Message::Scanner;
use base 'CIF::Message::Inet';

use strict;
use warnings;

__PACKAGE__->table('scanners');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    $info->{'impact'} = 'scanner';
    return $self->SUPER::insert($info);
}

1;
