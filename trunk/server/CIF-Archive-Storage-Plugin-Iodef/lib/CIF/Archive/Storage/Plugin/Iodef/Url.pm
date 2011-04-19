package CIF::Archive::Storage::Plugin::Iodef::Url;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return(0) unless($address);
    return(0) if($address =~ /[a-zA-Z0-9.-]+\.[a-z]{2,5}$/);
    return(1) if($address =~ /[a-zA-Z0-9.-]+\.[a-z]{2,5}/);
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
