package CIF::WebAPI::Plugin::rir;
use base 'CIF::WebAPI::Plugin';

sub prepare {
    my $self = shift;
    my $frag = shift;

    return unless($frag);
    $frag = uc($frag);
    return unless(isrir($frag));
    return(1);
}

sub isrir {
    my $rir = shift;
    return unless($rir);
    $rir = lc($rir);
    return unless($rir =~ /^(apnic|arin|ripencc|lacnic|afrinic)$/);
    return(1);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    if(isrir($frag)){
        $self->{'query'} = $frag;
        return $self;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
