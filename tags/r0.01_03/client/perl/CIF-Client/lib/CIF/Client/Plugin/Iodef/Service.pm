package CIF::Client::Plugin::Iodef::Service;

sub hash_simple {
    my $clas = shift;
    my $hash = shift;

    my $portlist = $hash->{'EventData'}->{'Flow'}->{'System'}->{'Service'}->{'Portlist'};
    my $protocol = $hash->{'EventData'}->{'Flow'}->{'System'}->{'Service'}->{'ip_protocol'};

    return({
        portlist    => $portlist,
        protocol    => $protocol,
    });
}
1;
