package CIF::Archive::Plugin::Iodef::Url;

use strict;
use warnings;

sub can {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return(1) if($address && $address =~ /[a-zA-Z0-9.-]+\.[a-z]{2,5}$/);
    return(0);
}

sub toIODEF {
    my $self = shift;
    my $info = shift;
    my $iodef = shift;

    my $address = lc($info->{'address'});

    return($iodef) unless($address && $address =~ /[a-zA-Z0-9.-]+\.[a-z]{2,5}$/);
    return($iodef) if($iodef->get('IncidentEventDataFlowSystemNodeAddressext-category'));

    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category','url');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    return $iodef;
}

1;
