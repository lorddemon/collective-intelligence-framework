package CIF::WebAPI::urls;

use base 'CIF::WebAPI';

use CIF::Message::URL;
use CIF::WebAPI::urls::url;
use CIF::WebAPI::urls::malware;
use CIF::WebAPI::urls::phishing;

sub GET {
    my ($self, $request, $response) = @_;

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * 30)));

    my @recs = CIF::Message::URL->search_feed($detecttime,10000);
    my @feed = @recs;

    $response->data()->{'result'} = \@feed;
    return Apache2::Const::HTTP_OK;
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    for(lc($frag)){
        if(/^malware$/){
            $subh = CIF::WebAPI::urls::malware->new($self);
            return $subh;
            last;
        }
        if(/^phishing$/){
            $subh = CIF::WebAPI::urls::phishing->new($self);
            return $subh;
            last;
        }
        $subh = CIF::WebAPI::urls::url->new($self);
        $subh->{'url'} = $frag;
        return $subh;
    }
}

1;
