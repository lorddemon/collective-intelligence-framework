package CIF::Archive::Storage::Plugin::Iodef::Ipv4;

use Regexp::Common qw/net/;
use XML::IODEF;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return(1) if($address && $address =~ /^$RE{'net'}{'IPv4'}/);
    return(0);
}

sub convert {
    my $class = shift;
    my $info = shift;
    my $iodef = shift;
    
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$info->{'address'});
    return($iodef);
}

1;
