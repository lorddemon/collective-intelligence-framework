package CIF::WebAPI::Plugin::url;
use base 'CIF::WebAPI::Plugin';

sub prepare {
    # this left blank; urls have to come in via:
    # url/<md5|sha1>
}

sub buildNext {
    my ($self,$frag,$req) = @_;    

    if(lc($frag) =~ /^([a-f0-9]{32})|([a-f0-9]{40})$/){
        $self->{'query'} = $frag;
        return $self;
    }
    return $self->SUPER::buildNext($frag,$req);
}

1;
