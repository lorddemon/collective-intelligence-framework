package CIF::Archive::Storage::Plugin::Iodef::Domain;
use base 'CIF::Archive::Storage::Plugin::Iodef';

sub prepare {
    my $class   = shift;
    my $info    = shift;
    
    my $address = $info->{'address'};
    return(1) if($address && $address =~ /^[a-zA-Z0-9.-]+\.[a-z]{2,5}$/);
    return(0);
}


sub to {
    my $self = shift;
    my $info = shift;

    my $address = lc($info->{'address'});
    my $iodef = $self->SUPER::to($info);
    

    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category','domain');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    
    if($info->{'rdata'}){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','rdata');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$rdata);

    }
    return $iodef->out();
}

1;
