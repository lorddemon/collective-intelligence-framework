package CIF::Archive::Json;

use strict;
use warnings;
use JSON;

sub to {
    my $self = shift;
    my $data = shift;
    my $json = to_json($data);

    $data->{'format'} = 'JSON';
    
    return($json);
}

sub from {
    my $self = shift;
    my $data = shift;
    return from_json($data);
}
    
1;
