package CIF::Archive::Storage::Plugin::Iodef::Domain;

sub prepare {
    my $class   = shift;
    my $info    = shift;
    
    my $address = $info->{'address'};
    return(1) if($address && $address =~ /^[a-zA-Z0-9.-]+\.[a-z]{2,5}$/);
    return(0);
}

sub data_hash_simple {
    my $class = shift;
    my $hash = shift;

    my $address = $hash->{'EventData'}->{'Flow'}->{'System'}->{'Node'}->{'Address'};
    $address = $address->{'content'} if(ref($address) eq 'HASH');
    return unless($address =~ /^[a-zA-Z0-9.-]+\.[a-z]{2,5}$/);

    my ($rdata,$type);
    my $ad = $hash->{'EventData'}->{'Flow'}->{'System'}->{'AdditionalData'};
    my @array;
    if(ref($ad) eq 'ARRAY'){
        @array = @$ad;
    } else {
        push(@array,$ad);
    }
    foreach my $a (@array){
        for(lc($a->{'meaning'})){
            $rdata  = $a->{'content'} if(/rdata/);
            $type   = $a->{'content'} if(/type/);
        }
    }
    
    return({
        rdata   => $asn,
        type    => $prefix,
        address => $address,
    });
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
