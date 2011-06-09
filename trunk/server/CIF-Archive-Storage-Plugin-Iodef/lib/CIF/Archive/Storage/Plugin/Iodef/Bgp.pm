package CIF::Archive::Storage::Plugin::Iodef::Bgp;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    return(1) if($info->{'prefix'});
    return(1) if($info->{'asn'});
    return(1) if($info->{'cc'});
    return(1) if($info->{'rir'});
    return(0);
}

sub data_hash_simple {
    my $class = shift;
    my $hash = shift;
    my $sh = shift;

    my ($asn,$prefix,$rir,$cc);

    my $ad = $hash->{'EventData'}->{'Flow'}->{'System'}->{'AdditionalData'};
    my @array;
    if(ref($ad) eq 'ARRAY'){
        @array = @$ad;
    } else {
        push(@array,$ad);
    }
    foreach my $a (@array){
        for(lc($a->{'meaning'})){
            $asn    = $a->{'content'} if(/asn/);
            $prefix = $a->{'content'} if(/prefix/);
            $rir    = $a->{'content'} if(/rir/);
            $cc     = $a->{'content'} if(/cc/);
        }
    }
    $sh->{'asn'} = $asn;
    $sh->{'prefix'} = $prefix;
    $sh->{'rir'} = $rir;
    $sh->{'cc'} = $cc;
    return($sh);
}

sub convert {
    my $self = shift;
    my $info = shift;
    my $iodef = shift;
    
    my $prefix  = $info->{'prefix'};
    my $asn     = $info->{'asn'}; 
    my $cc      = $info->{'cc'};
    my $rir     = $info->{'rir'};
    my $asn_desc = $info->{'asn_desc'};

    if($prefix){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','prefix');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$prefix);

    }
    if($asn){
        $asn .= ' '.$asn_desc if($asn_desc);
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','asn');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$asn);
    }
    if($cc){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','cc');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$cc);
    }
    if($rir){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','rir');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$rir);
    }
    return $iodef;
}

1;
