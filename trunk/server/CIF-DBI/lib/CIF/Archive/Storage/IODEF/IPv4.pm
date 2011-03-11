package CIF::Message::IODEF::IPv4;

use Regexp::Common qw/net/;

sub can {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return(1) if($address && $address =~ /^$RE{'net'}{'IPv4'}/);
    return(0);
}

sub toIODEF {
    my $self = shift;
    my $info = shift;
    my $iodef = shift;
    
    my $address = $info->{'address'};

    return($iodef) unless($address && $address =~ /^$RE{'net'}{'IPv4'}/);
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    return $iodef;
}

1;
