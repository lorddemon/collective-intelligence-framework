package CIF::Archive::Storage::Plugin::Iodef::Ipv4;

use Regexp::Common qw/net/;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return(1) if($address && $address =~ /^$RE{'net'}{'IPv4'}/);
    return(0);
}

sub data_hash_simple {
    my $clas = shift;
    my $hash = shift;
    my $sh = shift;

    my $address = $hash->{'EventData'}->{'Flow'}->{'System'}->{'Node'}->{'Address'};
    $address = $address->{'content'} if(ref($address) eq 'HASH');
    return unless($address && $address =~ /^$RE{'net'}{'IPv4'}/);

    return({
        address => $address,
    });
}

sub convert {
    my $class = shift;
    my $info = shift;
    my $iodef = shift;
    
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$info->{'address'});
    return($iodef);
}

1;
