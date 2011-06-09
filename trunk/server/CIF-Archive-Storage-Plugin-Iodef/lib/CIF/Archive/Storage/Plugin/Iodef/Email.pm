package CIF::Archive::Storage::Plugin::Iodef::Email;

use Regexp::Common qw/URI/;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return unless($address);
    return if($address =~ /^$RE{'URI'}/);
    return unless($address =~ /\w+@\w+/);
    return(1);
}

sub data_hash_simple {
    my $class = shift;
    my $hash = shift;

    my $address = $hash->{'EventData'}->{'Flow'}->{'System'}->{'Node'}->{'Address'};
    $address = $address->{'content'} if(ref($address) eq 'HASH');

    return({
        address => $address,
    });
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
