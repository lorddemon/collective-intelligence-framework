package CIF::Archive::Storage::Plugin::Iodef::Url;
use base 'CIF::Archive::Storage::Plugin::Iodef';

use strict;
use warnings;

require XML::IODEF;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return(0) unless($address);
    return(0) if($address =~ /[a-zA-Z0-9.-]+\.[a-z]{2,5}$/);
    return(1) if($address =~ /[a-zA-Z0-9.-]+\.[a-z]{2,5}/);
}

sub to {
    my $class = shift;
    my $info = shift;
    my $address = lc($info->{'address'});

    my $iodef = $class->SUPER::to($info);

    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category','url');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    return $iodef->out();
}

1;
