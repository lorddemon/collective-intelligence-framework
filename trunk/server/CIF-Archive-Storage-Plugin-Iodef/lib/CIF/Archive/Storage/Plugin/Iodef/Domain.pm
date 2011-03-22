package CIF::Archive::Storage::Plugin::Iodef::Domain;

sub prepare {
    my $class   = shift;
    my $info    = shift;
    
    my $address = $info->{'address'};
    return(1) if($address && $address =~ /^[a-zA-Z0-9.-]+\.[a-z]{2,5}$/);
    return(0);
}


sub convert {
    my $self = shift;
    my $info = shift;
    my $iodef = shift;

    my $address = lc($info->{'address'});
    

    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category','domain');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    
    if($info->{'rdata'}){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','rdata');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$rdata);

    }
    return($iodef);
}

1;
