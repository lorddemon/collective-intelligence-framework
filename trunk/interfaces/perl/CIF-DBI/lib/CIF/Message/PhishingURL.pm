package CIF::Message::PhishingURL;
use base 'CIF::Message::URL';

use strict;
use warnings;

use CIF::Message::IODEF;

__PACKAGE__->table('phishing_urls');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    $info->{'impact'} = 'phishing url' unless($info->{'impact'});
    return $self->SUPER::insert($info);
}
1;
