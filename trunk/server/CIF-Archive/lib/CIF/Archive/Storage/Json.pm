package CIF::Archive::Storage::Json;
use base 'CIF::Archive::Storage';

use strict;
use warnings;

require JSON;

sub to {
    my $self = shift;
    my $data = shift;

    my $json = JSON::to_json($data);

    
    return($json);
}

sub from {
    my $self = shift;
    my $data = shift;
    return JSON::from_json($data);
}
    
1;
