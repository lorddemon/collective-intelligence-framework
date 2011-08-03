package CIF::Archive::Storage::Json;
use base 'CIF::Archive::Storage';

use strict;
use warnings;

require JSON;

sub convert {
    my $self = shift;
    my $data = shift;

    my $json = JSON::to_json($data);
    return($json);
}

sub to_hash {
    my $self = shift;
    my $data = shift;
    return unless($self->{'format'} eq 'json');
    return JSON::from_json($data);
}
    
1;
