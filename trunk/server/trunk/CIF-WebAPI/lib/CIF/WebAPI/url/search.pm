package CIF::WebAPI::urls::searches;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::UrlSearch;

sub GET {
    my ($self, $request, $response) = @_;

    if(exists($self->{'address'})){
        my $arg = $self->address();
        my $col = 'address';
        if($arg =~ /^[a-fA-F0-9]{32}$/){
            $col = 'url_md5';
        } elsif($arg =~ /^[a-fA-F0-9]{40}$/){
            $col = 'url_sha1';
        }
        my @recs = CIF::Message::UrlSearch->search($col => $arg);
        if(@recs){
            my @res = map { CIF::WebAPI::urls::mapIndex($_) } @recs;
            $response->data()->{'result'} = \@res;
        }
    }
    return Apache2::Const::HTTP_OK;
}

sub buildNext {
    my ($self,$frag,$req) = @_;
    
    my $h = CIF::WebAPI::urls::searches->new($self);
    $h->{'address'} = $frag;
    return $h;
}

1;
