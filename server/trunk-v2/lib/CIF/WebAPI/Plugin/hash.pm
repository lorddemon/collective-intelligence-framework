package CIF::WebAPI::Plugin::hash;
use base 'CIF::WebAPI::Plugin';

use CIF::Archive::DataType::Plugin::Hash;

sub prepare {
    my $self = shift;
    my $frag = lc(shift);

    my @plugs = CIF::Archive::DataType::Plugin::Hash->plugins();
    foreach(@plugs){
        return(1) if($_->lookup($frag));
    }
    return(0);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    if($self->prepare($frag)){
        $self->{'query'} = $frag;
        return($self);
    }
    return($self->SUPER::buildNext($frag,$req));
}
1;
