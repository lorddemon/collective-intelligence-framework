package RINO::Client::Plugin::Json;

use strict;
require JSON;

sub write_out {
    my $class = shift;
    my $ref = shift;
    my @array = @{$ref};
    @array = splice(@array,1,$#array);

    return JSON::to_json(\@array);
}

1;
