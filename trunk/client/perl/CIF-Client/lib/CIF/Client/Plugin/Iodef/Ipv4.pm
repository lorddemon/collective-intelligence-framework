package CIF::Client::Plugin::Iodef::Ipv4;

use Regexp::Common qw/net/;

sub hash_simple {
    my $clas = shift;
    my $hash = shift;

    my $address = $hash->{'EventData'}->{'Flow'}->{'System'}->{'Node'}->{'Address'};
    for(ref($address)){
        if(/HASH/){
            $address = $address->{'content'};
            last;
        }
        if(/ARRAY/){
            my @ary = @{$address};
            $address = $ary[$#ary]->{'content'};
            last;
        }
    }
    return unless($address && $address =~ /^$RE{'net'}{'IPv4'}/);

    my $portlist = $hash->{'EventData'}->{'Flow'}->{'System'}->{'Service'}->{'Portlist'};
    my $protocol = $hash->{'EventData'}->{'Flow'}->{'System'}->{'Service'}->{'ip_protocol'};

    return({
        address     => $address,
        portlist    => $portlist,
        protocol    => $protocol,
    });
}
1;
