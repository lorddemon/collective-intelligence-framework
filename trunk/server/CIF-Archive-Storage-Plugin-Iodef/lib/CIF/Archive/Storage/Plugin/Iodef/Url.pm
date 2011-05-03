package CIF::Archive::Storage::Plugin::Iodef::Url;

use Regexp::Common qw /URI/;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return(0) unless($address);
    return(1) if($address =~ /$RE{URI}{HTTP}/);
    return(0);
}

sub convert {
    my $class = shift;
    my $info = shift;
    my $iodef = shift;

    my $address = lc($info->{'address'});

    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category','url');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    return($iodef);
}

1;
