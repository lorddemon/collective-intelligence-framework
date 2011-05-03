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
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$info->{'rdata'} || '');
        $iodef = CIF::Archive::Storage::Plugin::Iodef::Bgp->convert($_,$iodef);

        # don't add TTL's, you'll screw up the duplicate detection, it changes every time you add a domain ;-)
        # we build it into the index, but not the orig message.
        #$iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        #$iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','ttl');
        #$iodef->add('IncidentEventDataFlowSystemAdditionalData',$_->{'ttl'} || '');

    }
    $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
    $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','type');
    $iodef->add('IncidentEventDataFlowSystemAdditionalData',$info->{'type'} || 'A');

    return($iodef);
}

1;
