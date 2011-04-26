package CIF::WebAPI::Plugin::url;
use base 'CIF::WebAPI::Plugin';

# Plugin::Hash pics up the prepare

sub buildNext {
    my ($self,$frag,$req) = @_;    

    if(lc($frag) =~ /^([a-f0-9]{32,40})$/){
        $self->{'query'} = $frag;
        return $self;
    }
    return $self->SUPER::buildNext($frag,$req);
}

1;
