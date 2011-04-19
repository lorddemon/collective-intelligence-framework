package CIF::Archive::Storage::Plugin::Iodef::Email;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return(0) unless($address);
    return(1) if($address =~ /\w+@\w+/);
}

sub convert {
    my $self = shift;
    my $info = shift;
    my $iodef = shift;
    
    my $address = $info->{'address'};
    return($iodef) unless($address);
    return($iodef) unless($address =~ /\w+@\w+/);

    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','e-mail');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    return $iodef;
}

1;
