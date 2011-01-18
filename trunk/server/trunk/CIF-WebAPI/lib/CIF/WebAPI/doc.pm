package CIF::WebAPI::doc;
use base 'CIF::WebAPI';

use warnings;
use strict;

use CIF::FeedTables;
use Apache2::ServerRec;

my $examples = {
    'ipv4-net'  => '192.168.1.0/24',
    'ipv4'      => '192.168.1.1', 
    'url'       => 'url/246c9fa16cdc19411ace5cb43c301d2c',
    'malware'   => '71eb3bcdb9dcc0fe4a0089db62692318',
    'domain'    => 'example.com',
};

sub GET {
    my ($self,$req,$resp) = @_;

    my $agent = $req->{'r'}->headers_in->{'User-Agent'};
    return Apache2::Const::HTTP_OK unless(lc($agent) =~ /(mozilla|msie|chrome|safari)/);

    my $hostname = $req->{'r'}->hostname();
    my $apibase = $req->{'r'}->dir_config('Apache2RESTAPIBase') || '';
    my $r = $req->{'r'};
    my $apikey = $r->param('apikey');
    my $port = $r->server->port();
    my $proto = ($port == 443) ? 'https://' : 'http://';
    $hostname = $proto.$hostname;
    $hostname = $hostname.':'.$port if($port != 80 && $port != 443);
    
    my $url = $hostname.$apibase;

    my $t = CIF::FeedTables->new();
    my @x = map { $_->relname() } $t->search__feed_tables();
    my $table = Text::Table->new('Feed','Example');
    $req->requestedFormat('text');
    foreach (@x){ 
        $_ =~ s/feed_//; 
        $_ =~ s/\_/\//; 
        $table->load([$_,$url.'/'.$_.'?apikey='.$apikey.'&severity=medium']);
    }

    my $t2 = Text::Table->new('Query','Example');
    foreach my $k (keys %$examples){
        $t2->load([$k,$url.'/'.$examples->{$k}.'?apikey='.$apikey]);
    }
    $table = $table."\n\n".$t2;
    $resp->{'data'}->{'result'} = $table;
    return Apache2::Const::HTTP_OK;
}
1;
