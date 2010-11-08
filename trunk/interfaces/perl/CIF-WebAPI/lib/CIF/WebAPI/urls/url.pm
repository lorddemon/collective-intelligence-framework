package CIF::WebAPI::urls::url;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::URL;

sub GET {
    my ($self, $request, $response) = @_;

    my $arg = $self->url();
    my $q;
    if($arg =~ /^[a-fA-F0-9]{40}$/){
        $q = 'url_sha1';
    }
    if($arg =~ /^[a-fA-F0-9]{32}$/){
        $q = 'url_md5';
    }
    return Apache2::Const::HTTP_OK unless($q);

    my @recs = CIF::Message::URL->search($q => $arg);
    unless(@recs){ return undef; }

    @recs = map { CIF::WebAPI::urls::mapIndex($_) } @recs;
    
    $response->data()->{'result'} = \@recs;
    return Apache2::Const::HTTP_OK;
}

1;
